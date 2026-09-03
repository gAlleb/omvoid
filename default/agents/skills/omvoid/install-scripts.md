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

## Migrations

An install step only helps a machine being set up. When an **already installed**
machine needs repairing — a file moved, a stale cache removed, a symlink
repointed — that is a migration: a script in `migrations/` named after the unix
time it was created, so sorting by name is the execution order.

```bash
omvoid-dev-add-migration "move mise wrappers to the new directory"
omvoid-migrate --pending   # list what has not run
omvoid-migrate             # run them
```

Markers live in `~/.local/state/omvoid/migrations/`. Each migration runs in its
own `bash -euo pipefail`, so a failure takes neither the others nor the caller
down, and leaves no marker — it retries on the next update.
`install/preflight/migrations.sh` stamps every existing migration as done during
a fresh install, because a machine built from the current repo needs no historical
repairs.

Reach for a migration only when a repo change alone cannot fix an installed
machine. Shipping a new file is not one: it arrives on its own.

## Updating an installed machine

`omvoid-update` is the whole path: `git pull`, system packages, then the config
sync, migrations, `mise up`, skill relinking, reloads, and finally
`omvoid-hook post-update` for anything machine-specific.

The sync step matters because the repo reaches `$HOME` by copying, and
`install.sh` will not repeat those steps once their markers exist. It covers
every directory the install deploys, not just `config/`: `applications/*.desktop`
and the icons, `install/apps/files/*` (vendored executables that land in
`~/.local/bin`), and the `default/` dotfiles. The path table lives in
`omvoid-refresh-config`; ask it with `--where <repo-path>` rather than
duplicating it. It lists files
that diverged and lets you pick per file — never blanket-overwrite. Some paths
are deliberately excluded because the system owns them after installation
(`rclone/rclone.conf` is an empty placeholder in git, `nvim/lazy-lock.json` is
written by lazy.nvim, `bg.jpg` is generated). Add to that list rather than
letting an update destroy live state.

## Style of existing steps

Plain sequential shell, comments explaining *why* rather than what. Look at
`install/development/mihomo.sh` for the "not in Void repos" pattern and
`install/desktop/theme.sh` for the "clone, build, symlink" pattern.

`install/preflight/guard.sh` runs on every invocation, never marker-gated.
Put anything that must be re-checked each time there.
