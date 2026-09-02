# mise and lazy CLI wrappers

Runtimes and CLI tools are managed by [mise](https://mise.jdx.dev), installed
from Void repos in `install/development/mise.sh`. nvm was replaced by it; the old
nvm lines survive commented out in `default/.bashrc` and
`install/development/node.sh`.

Two mechanisms put mise-managed things on PATH:

- `eval "$(mise activate bash)"` in `default/.bashrc` — interactive shells only.
- `~/.local/share/mise/shims` appended to PATH in `default/.bash_profile` — works
  in scripts and services too, where `.bashrc` is never read.

## Lazy wrappers

`omvoid-mise-install <package> [command] [bin]` writes a ~200-byte file into
`~/.local/bin` that installs the tool on first use and then runs it:

```bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "<package>" || exit 1
exec mise x "<package>" -- "<bin>" "$@"
```

So the command exists on PATH from first boot while nothing is downloaded until
it is actually run — the install of the whole distribution is not lengthened by
any number of wrapped CLIs. `MISE_MINIMUM_RELEASE_AGE=0` is deliberate: mise
holds fresh releases back for days by default, and agent CLIs ship almost daily.

Arguments: the **package** is what mise resolves (bare names go through mise's
registry and usually arrive as native binaries via the `aqua` backend, not npm);
the **command** is the filename created; the **bin** is the executable inside the
package. Only pass the extra arguments when the names differ —
`omvoid-mise-install antigravity-cli agy`, `omvoid-mise-install npm:@xai-official/grok grok`.

Companions: `omvoid-mise-list` (what is wrapped, and whether it has been
downloaded yet), `omvoid-mise-uninstall [--purge]`, `omvoid-update-mise`
(`mise up` with the release cooldown disabled).

## The rule that must not be relaxed

`~/.local/bin` also holds **hand-written personal scripts**. Unlike Omarchy,
where that directory belongs to the distribution, here it is shared. So
`omvoid-mise-install` refuses to overwrite any file that does not carry the
`# omvoid-mise-stub` marker, and `omvoid-mise-uninstall` refuses to delete one.
Keep that check. Getting a name wrong would otherwise destroy the user's script.

It also warns when the command already exists elsewhere on PATH, because a
wrapper either shadows the real tool or is dead weight depending on directory
order.

To wrap another tool, add a line to `install/development/mise.sh`. Nothing else
needs editing.
