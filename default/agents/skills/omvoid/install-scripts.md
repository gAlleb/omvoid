# Install steps

`install.sh` is the whole installer: a preflight guard, then a list of
`run_step` calls grouped into stages that print a banner each.

## How a step runs

```bash
run_step() {
  local marker="$OMVOID_STATE/$1"
  if [ -f "$marker" ]; then
    echo "skip $1 (already done)"
    return 0
  fi
  source "$OMVOID_INSTALL/$1"
  mkdir -p "$(dirname "$marker")"
  touch "$marker"
}
```

Three consequences that shape how steps are written:

1. **Steps are `source`d, not executed.** They share the installer's shell.
   Never call `exit` — it kills the whole install. No shebang is needed
   (harmless if present, and most steps have one). Variables leak between
   steps; do not rely on that, but do not fight it either.
2. **A completed step leaves a marker** in `~/.local/state/omvoid/done/<group>/<step>.sh`
   and is skipped forever after. The installer is therefore resumable: after a
   failure, re-running `bash ~/.local/share/omvoid/install.sh` picks up where it
   stopped. State lives outside the repo so `install.sh` itself is never mutated.
3. **`set -e` is active** and `trap ERR` prints a retry hint. A command that may
   legitimately fail must end in `|| true`.

Everything is logged to `~/.local/state/omvoid/install.log`.
`sudo` is cached and kept alive for the whole run, so steps may use it freely
without prompting mid-install.

## Adding a step

1. Create `install/<group>/<name>.sh`. Groups are `preflight`, `config`,
   `development`, `desktop`, `apps`.
2. Add `run_step <group>/<name>.sh` to `install.sh` in the right stage.
3. Make it **idempotent anyway.** The marker protects a normal run, but the step
   will be run by hand during development. Guard with `[ -d ... ]`,
   `ln -sfn`, `mkdir -p`, `xbps-install -y` (already-installed is not an error).

To re-run a step that has already completed, delete its marker:

```bash
rm ~/.local/state/omvoid/done/development/mise.sh
```

See [`updating.md`](updating.md) for migrations and for how a change
reaches a machine that is already installed.

## Style of existing steps

Plain sequential shell, comments explaining *why* rather than what. Look at
`install/development/mihomo.sh` for the "not in Void repos" pattern and
`install/desktop/theme.sh` for the "clone, build, symlink" pattern.

`install/preflight/guard.sh` runs on every invocation, never marker-gated.
Put anything that must be re-checked each time there.
