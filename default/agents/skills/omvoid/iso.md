# The installation image

An OMVOID image is not a snapshot of a working system. It carries three things:
a small live system, a mirror of every package OMVOID installs, and the
installer. A machine is configured by running OMVOID's own `install.sh` inside
it — the same script that configures a machine installed the long way.

That is the whole design, and the reason for it is that there is then one
description of an OMVOID system instead of two. An image built by baking a
configured system into it becomes a second source of truth, and it drifts from
`install/` silently: the drift only shows up on a machine installed from it,
days later.

Omarchy's ISO works the same way, and reading it settled the question:

    chroot_bash -lc "source /home/$OMARCHY_USER/.local/share/omarchy/install.sh"

## Building one

Three steps, in order. They are separate on purpose.

    omvoid-pkg-mirror      fill the package mirror
    omvoid-iso-build -f    build the image (-f is a quick draft)
    omvoid-iso-test -n     boot it in qemu against a fresh disk

`omvoid-pkg-mirror` downloads every package OMVOID installs, and everything
those depend on, from the repositories in `install/lib/sources.sh`. This is the
moment the image's package versions are chosen, which is why it is a deliberate
step and not part of the build.

It resolves against an empty root. Without that, xbps works out what the *build
machine* is missing and leaves out everything already installed there — the
mirror then has holes that only appear on a target where those packages are
genuinely absent.

## What the installer does

`omvoid-install` runs on the first console of the live system.

1. asks everything up front, and writes the answers to a file, so an
   unattended install is a matter of putting that file on the medium;
2. partitions, optionally with LUKS;
3. installs the packages into `/mnt` from the mirror — no network involved;
4. creates the user;
5. runs `install.sh` inside the new system, as that user, with
   `OMVOID_IN_CHROOT=1` set;
6. writes the repository configuration and their keys, so the installed
   machine gets updates from the people who maintain those packages.

Step 6 is last for a reason. `install.sh` calls `xbps-install -S` in several
places, which syncs every configured repository; with the third-party ones
already written that means reaching over a network the machine may not have,
and `repo.voiders.dev` does not refuse — it redirects and goes quiet, which has
hung a build for a quarter of an hour. Until then the only repository the new
system has is the mirror, which syncs instantly and offline.

## Writing install steps that survive a chroot

Most steps need nothing special. Three things do not work in a chroot, and each
has a fixed answer:

| | |
|---|---|
| enabling a service | `omvoid-service-enable`, never `ln -s /etc/sv/x /var/service` |
| anything needing a session (`gsettings`, `awww`) | guard with `[[ -z ${OMVOID_IN_CHROOT:-} ]]` and let `omvoid-cmd-first-run` do it |
| asking the person a question | read the installer's answers from `~/.local/state/omvoid/install-answers` |
| anything that downloads | there is no network. Bake it onto the medium, or record the intent and let first use fetch it — `mise.sh` writes the version pin when `mise use` cannot reach anything |
| rebooting | never from a chroot: `/proc` is the live system's, so it restarts the machine that is running the install. Guard with `OMVOID_IN_CHROOT` and leave it to the wizard |
| background loops | they outlive the step and hold the target open, and the wizard then cannot unmount it. The sudo keepalive in `install.sh` is skipped in a chroot for exactly this |

`/var/service` is a symlink to `../run/runit/runsvdir/current`, and `/run` is a
tmpfs made at boot. In a system being installed it points at nothing, every link
fails silently, and the machine comes up with no services at all — no network,
no display manager, nothing. This is not hypothetical: it is what the first
image-installed machine did.

## Packages

Anything not in Void's repositories is packaged in `srcpkgs/`, built with
`omvoid-pkg-build <name>`, and published with `omvoid-pkg-publish`. The package
list for the image is read out of the `xbps-install` lines in `install/` by
`omvoid-iso-packages`, so adding a package to an install step is all that is
needed — there is no second list to keep in step.

Two templates in `srcpkgs/` are references only, never built here:
`brave-origin-bin` and `noctalia` come from their own maintainers, who follow
their releases. `omvoid-pkg-build` requires names, so it never builds them by
accident.

## Traps already fallen into

- **`ext3fs.img`** — recent dracut looks for `rootfs.img`; void-mklive still
  writes the old name, and the image then builds cleanly and fails to boot with
  "Cannot find init!". `omvoid-iso-build` patches it (upstream #459).
- **A build root with no shell** — `xbps-src` removes host dependencies when it
  finishes, and `bash` is one of them; `/bin/sh` in the build root points at it.
  The *next* build then dies complaining about `/void-packages/xbps-src`, which
  says nothing about a missing shell. `omvoid-pkg-build` rebuilds the root when
  it finds no shell.
- **WhiteSur's installer is silent** — it sends its stderr to a file it deletes
  on exit, runs under `set -Eeo pipefail`, and calls `setterm`, which fails when
  `TERM` is unset or `dumb`. Its template sets `TERM=linux` and undoes the
  redirect.
- **Who owns the user's home** — the wizard writes into `/home/<user>` as root,
  so the `chown -R` has to come *last*. Done any earlier, `~/.local/state/omvoid`
  stays root-owned, and `install.sh` dies on its very first line: `mkdir -p`
  succeeds on the existing directory, `tee` cannot write the log, output goes to
  a broken pipe. What you get is "OMVOID installation failed" with no log and no
  step markers — nothing that points at ownership.
- **`gsettings` with no session bus** — installing from the medium there is
  neither a bus nor an `/etc/machine-id` to autolaunch one, so the three writes
  in `theme.sh` fail and `set -e` ends the install on the theme. Run them under
  `dbus-run-session`: dconf still lands in `~/.config/dconf/user`, which the real
  session reads at first login.
- **Drivers left out of the mirror** — `config/gpu.sh` installs by detected
  vendor, so baking only what this machine needs looks right. Offline a missing
  package is not a slower install, it is a dead one. Both Intel drivers are a few
  megabytes against a four-gigabyte image; they stay in.
- **Success reported by inference** — three separate times a tool said it had
  done something it had not. `omvoid-pkg-mirror` ended on `$verbose && ls ...`,
  which returns 1 when `-v` is off, so a perfect mirror reported failure. It
  called `omvoid-iso-packages` through `PATH`, which a detached shell does not
  have, so the list came back empty and the mirror was silently left as it was.
  And `omvoid-iso-build` reported the image at `$output` without checking that
  *this* run produced it — mklive traps signals, cleans up and still exits zero,
  so an interrupted build chowned the previous image and printed its size. Check
  the thing itself, not a proxy for it.
- **Which sudoers file wins** — the wizard opens passwordless sudo for the
  duration of `install.sh`, because there is nobody in a chroot to type a
  password. Named `00-omvoid-install` it was read *before* `wheel`, and sudoers
  gives the last matching rule, so the ordinary `%wheel` line took it straight
  back: `sudo -v` on install.sh's third line failed with "a terminal is required
  to read the password". The file has to sort after every other rule for the
  user — hence `zz-omvoid-install`.
- **`sudo -v` is not `sudo`** — it refuses to be satisfied by a NOPASSWD rule
  while an ordinary `%wheel` rule also matches the user, and asks for a password
  no matter what. In a chroot nobody can type one, so install.sh died on its
  third line while plain `sudo` worked perfectly two lines later. Skipped when
  `OMVOID_IN_CHROOT` is set, along with the credential keepalive.
- **`set -eu` inside a step** — steps under `install/` are *sourced*, so options
  set in one stay on for every step after it. `config/swap.sh` carried
  `set -eu`, and `-u` turned the next step into an abort on the first unset
  variable. install.sh sets `-e` once, for all of them; a step should not set
  shell options at all.
- **A step that only exports** — `run_step` marks a step done and skips it next
  time, which is right for a step that changes the machine and wrong for one
  that only sets variables. `config/identification.sh` was gated that way, so
  every retry after a later failure ran with the identity variables unset. It is
  sourced directly now, and the interactive path saves its answers to the same
  file the image installer writes.
- **`mise config set` needs the file to exist** — the offline fallback for
  pinning node ("write the version without downloading it") fails on a fresh
  machine with "config file not found". Node is an `omvoid-mise-install` stub
  like every other tool instead: no network at install time, version still
  pinned, fetched on first use.
