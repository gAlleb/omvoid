# Packages on Void: xbps and xbps-src

Two separate tools with similar names. `xbps-*` manages packages on a machine;
`xbps-src` builds them from templates in a checkout of void-packages.

## Using packages

    xbps-install -Su                 update everything (xbps itself first)
    xbps-install -y foo bar          install
    xbps-install -S                  refresh repository indexes only
    xbps-remove -Ry foo              remove, and what only foo needed
    xbps-remove -Oy                  drop the downloaded package cache
    xbps-remove -oy                  remove orphans
    xbps-query -l                    what is installed
    xbps-query -f foo                which files a package owns
    xbps-query -o '*/bin/mw'         which package owns a file
    xbps-query -R -p pkgver foo      the version the repositories offer
    xbps-query -p pkgver foo         the version installed
    vkpurge list / vkpurge rm all    old kernels, which nothing else removes

`-R` means "ask the repositories". Note that `--repository=URL` **adds** a
repository to the configured list rather than replacing it: a query with it
still answers from all of them, which makes it useless for asking what one
particular repository holds.

## Repositories

Configured by one file each in `/etc/xbps.d/`, holding a single line:

    repository=https://raw.githubusercontent.com/galleb/omvoid-repo/repository-x86_64-glibc

Each needs its signing key in `/var/db/xbps/keys/<fingerprint>.plist`, or xbps
asks whether to trust the fingerprint — and an unattended install has nobody to
answer. omvoid keeps its keys in `default/repokeyes/` and installs them in
`install/development/omvoid-repo.sh`.

Fetched indexes are cached under `/var/db/xbps/<url-with-underscores>/`. Their
timestamps read as 1970 because GitHub sends no useful `Last-Modified`; that is
not a sign of a failed sync.

**After pushing to a repository on GitHub, `xbps-install -S` can still bring the
previous index for up to five minutes** — raw.githubusercontent.com answers with
`cache-control: max-age=300`, and the response carries a `source-age` header
showing how stale the copy is. The sync succeeds and the content is old. Either
wait, or install from the local directory with `--repository`.

## Building packages

omvoid's templates live in `srcpkgs/`, and `omvoid-pkg-build <name>` copies one
into the void-packages checkout and builds it there:

    ~/.local/pkgs/void-packages/        the checkout, cloned on first use
      masterdir-x86_64/                 the build root (binary-bootstrap)
      hostdir/binpkgs/                  what came out

A template is a shell fragment: `pkgname`, `version`, `revision`, `build_style`,
`distfiles`, `checksum`, and optional phases like `post_install`. For a snapshot
of a branch rather than a release, name the commit and match `wrksrc` to the
directory inside the archive:

    _commit=b4a28b2548e94c167bb74fcb5e8c44c34d2be842
    version=3.3.1.20260726
    distfiles="https://github.com/user/repo/archive/${_commit}.tar.gz"
    wrksrc="repo-${_commit}"

## Publishing

`omvoid-pkg-publish` copies from `hostdir/binpkgs` into
`~/.local/github/omvoid-repo`, then:

    xbps-rindex -a <repo>/*.xbps      register them in the index
    xbps-rindex -c <repo>             drop entries for packages no longer there
    xbps-rindex --sign --signedby ... sign the index
    xbps-rindex --sign-pkg ...        sign each package

Adding a newer version replaces the older one *in the index* but leaves its file
in the directory; delete it separately.

## Traps

- **`/usr/local` cannot be packaged.** `common/hooks/pre-pkg/99-pkglint.sh`
  refuses `usr/local`, `var/run` and `usr/etc` outright, with no per-package
  exception. Programs whose upstream default is `/usr/local` — mutt-wizard among
  them — have to be packaged into `/usr`, and configuration they generated before
  needs rewriting.
- **A failed build leaves a finished destdir.** xbps-src records completed
  phases, so a second run after a template change can skip `install` and package
  the *previous* result: a changed `PREFIX` appears to be ignored. Run
  `./xbps-src clean <pkg>` after editing a template.
- **The build root loses its shell.** xbps-src removes host dependencies when it
  finishes, `bash` among them, and `/bin/sh` points at it. The *next* build fails
  complaining about `/void-packages/xbps-src`, which says nothing about a missing
  shell. `omvoid-pkg-build` rebuilds the root when it finds none — and tests for
  it without sudo, because a failed sudo would look exactly like a missing shell.
- **Fonts need `font_dirs`.** A font package that declares it gets xbps's
  `fc-cache` trigger; without it the fonts install and no application sees them.
  With it, a manual `fc-cache -f` afterwards is redundant work.
- **Packages that bake their prefix.** Some write their install path into files
  they generate later. Check what the upstream Makefile substitutes: mutt-wizard
  rewrites `/usr/local` to `$(PREFIX)` in its own scripts, which is why passing
  `PREFIX` is enough and no patch is needed.
