# Updating an installed machine

An install step only helps a machine being set up. Everything below is about the
machines that already exist — and there are several, so a change that only lands
on the one you are typing on is a change that will be lost.

## How the repo reaches a machine at all

`omvoid-update` is the whole path: `git pull`, system packages, the file sync,
migrations, `mise up`, skill relinking, reloads.

The file sync exists because the repo reaches `$HOME` by **copying**, and
`install.sh` will not repeat a step once its marker exists. So a plain `git pull`
changes nothing outside `bin/` and `themes/`, which are live from the repo.

These are the pairs the sync walks. The table itself lives in
`omvoid-refresh-config`; ask it with `--where <repo-path>` rather than
duplicating it anywhere:

| repo | machine |
|---|---|
| `config/*` | `~/.config/` |
| `applications/*.desktop` | `~/.local/share/applications/` |
| `applications/icons/*` | `~/.local/share/icons/hicolor/48x48/apps/` |
| `install/apps/files/*` | `~/.local/bin/` |
| `default/.bashrc`, `.bash_profile`, `.gtkrc-2.0`, `gnupg/*` | `$HOME` |

A file missing on the machine counts as diverged too, so dropping a new
executable into `install/apps/files/` is enough to have it offered — no new
install step, and the exec bit survives the copy.

## Nothing is overwritten silently

`omvoid-update` lists what diverged and lets you pick per file. The previous
version is kept as `<file>.bak.<epoch>` and the diff is printed.

`omvoid-update -y` **replaces nothing** — it only reports. That mode is for cron
and for a second machine "without looking", and a divergence there usually means
a hand edit on the live file. Losing it silently is worse than not updating a
config.

The reverse direction is `omvoid-refresh-config --capture <path>`: take the live
file into the repo. Both directions are needed because edits genuinely happen on
both sides — a live file gets tweaked in passing and moves ahead, and without a
way back that tweak dies at the next update.

## What the sync must never touch

Some files the repo ships once and the system owns afterwards. Their divergence
is normal, not something to repair. The list lives in `is_runtime_owned` inside
`omvoid-update`, each entry with the reason:

- `rclone/rclone.conf` — an empty placeholder in git, the live file is the real one
- `nvim/lazy-lock.json` — written by lazy.nvim
- `bg.jpg`, `*.so` — generated or built
- `crystal-dock/*` — the app writes its own state there
- `mango/conf/autostart.conf` — `omvoid-cmd-first-run` deletes its own line from
  it after the first boot, and per-machine things live there (screen brightness,
  gpg unlock, autostarts)
- `mango/conf/monitors.conf`, `hypr/config/monitors.conf` — geometry, scale and
  output names belong to a particular laptop and monitor
- everything `omvoid-font-set` rewrites: `alacritty/font.toml`, `kitty/kitty.conf`,
  `ghostty/config`, `fontconfig/fonts.conf`, `swayosd/style.css`, `mako/config`,
  `wal/templates/dunstrc`, every `rofi/*.rasi` — their divergence *is* the font
  you picked
- anything containing `__USERNAME__` — a template the installer substitutes.
  Detected by content, not by a list, so a new one is covered automatically

Add to that list rather than letting an update destroy live state. The list only
governs the automatic scan: `omvoid-refresh-config` knows nothing about it, so a
migration can still touch an excluded file deliberately.

## Migrations

A repo change can deliver a file. It cannot **remove** one that is no longer in
the repo, move it, or repair state on a machine you are not sitting at. That is
what a migration is: a script in `migrations/`, named after the unix time it was
created so sorting by name is the execution order.

```bash
omvoid-dev-add-migration "drop walker: removed from omvoid"
omvoid-migrate --pending   # list what has not run
omvoid-migrate             # run them (omvoid-update does this for you)
```

Markers live in `~/.local/state/omvoid/migrations/` — a different set from the
install-step markers in `~/.local/state/omvoid/done/`. Each migration runs in its
own `bash -euo pipefail`, so a failure takes neither the others nor the caller
down, and leaves no marker: it retries at the next update.

**A migration must be committed and pushed.** It travels like any other repo
file. Running fine locally proves nothing about the other machines — and an
uncommitted one also makes `omvoid-update` skip `git pull`, quietly stalling
everything else.

Reach for a migration only when a repo change alone cannot do the job. Shipping a
new file is not such a case; it arrives on its own.

### The stamping step

`install/preflight/migrations.sh` marks every existing migration as done —
but only on a genuinely fresh install, where a machine built from the current
repo needs no historical repairs. It tells the two situations apart by looking
for any install-step marker: the step runs first in `install.sh`, so on a fresh
machine there are none yet.

Without that guard, running `install.sh` on a long-established machine to pick up
new steps would stamp pending migrations as done and silently cancel exactly what
they were written for.

## Bringing a second machine up to date

`omvoid-update` updates what is already deployed; it does not run install steps.
New steps (a new tool, a new mechanism) arrive only through `install.sh`, which is
safe to re-run: everything with a marker is skipped and only the new steps
execute.

```bash
cd ~/.local/share/omvoid && git pull
bash ~/.local/share/omvoid/install.sh
omvoid-update
```

Expect many divergences on a machine that has never been synced — those are two
machines differing, not forgotten edits. Select only what genuinely must be the
same everywhere.
