# OMVOID Manual

OMVOID turns a bare [Void Linux](https://voidlinux.org/) installation into a
configured desktop built around [MangoWC](https://github.com/DreamMaoMao/mango),
a dwl-based Wayland compositor. It is not a package: it is a git checkout that
stays on the machine at `~/.local/share/omvoid` and keeps owning its configs.

This manual is for using and living with an installed system. For working on
OMVOID itself, see [AGENTS.md](AGENTS.md) and the guides under
`default/agents/skills/omvoid/`.

## Contents

- [Installing](#installing)
- [Everyday commands](#everyday-commands)
- [Themes and wallpapers](#themes-and-wallpapers)
- [Keeping several machines in sync](#keeping-several-machines-in-sync)
- [Migrations](#migrations)
- [AI coding agents](#ai-coding-agents)
- [Adding your own things](#adding-your-own-things)
- [Where things live](#where-things-live)
- [Troubleshooting](#troubleshooting)

## Installing

On a fresh Void installation, from your user shell:

```bash
curl -fsSL https://raw.githubusercontent.com/gAlleb/omvoid/refs/heads/main/boot.sh | bash
```

The installer asks for your password a few times and offers a reboot at the end.

It runs as a list of **steps**, each marked done in
`~/.local/state/omvoid/done/`. A failed run is resumable — just start it again
and completed steps are skipped. The same property makes it safe to re-run later
to pick up steps added since: everything old is skipped, only the new runs.

```bash
bash ~/.local/share/omvoid/install.sh
```

The whole run is logged to `~/.local/state/omvoid/install.log`.

## Everyday commands

Every command is `omvoid-<verb>-<noun>` and lives in `bin/`, which is on your
PATH straight from the repo — so editing one takes effect immediately.

| | |
|---|---|
| `omvoid-update` | pull the repo, update the system, sync files, run migrations |
| `omvoid-theme-next`, `omvoid-theme-set <name>`, `omvoid-theme-list` | curated themes |
| `omvoid-font-set <name>`, `omvoid-font-list` | change the font everywhere at once |
| `omvoid-menu-keybindings` | every keybinding in a searchable list |
| `omvoid-app-menu` | application launcher (`ALT+O`) |
| `omvoid-launch-tui <cmd>` | open a TUI in a floating window |
| `omvoid-reload-waybar` | reload the bar (`SUPER+W`) |
| `omvoid-toggle-idle`, `omvoid-toggle-waybar` | idle inhibitor, hide the bar |
| `omvoid-cmd-screenshot`, `omvoid-cmd-screenrecord` | capture |
| `omvoid-webapp-install`, `omvoid-tui-install` | add a web app or a TUI to the menu |

`ALT+W` opens the wallpaper picker. Media, volume and brightness keys work as
expected through `swayosd` and `playerctl`.

## Themes and wallpapers

Colour lives in one place: **pywal**. Whatever changes the look ends by running
`wal`, which writes `~/.cache/wal/`. Everything else either imports from there or
is told to reload. There are two ways in.

**`ALT+W` — the wallpaper picker.** Pick an image from `~/.config/wallpaper`,
choose Dark or Light, and the palette is derived from the picture. This is the
one that gives you endless themes. `🎨 Switch Theme` inside it re-runs only the
light/dark half, keeping the current wallpaper.

**Curated themes.** `themes/<name>/` carries a fixed palette, an icon theme and
its own backgrounds. Switch with `omvoid-theme-next` or `omvoid-theme-set <name>`.
Themes are symlinked into `~/.config/omvoid/themes/`, so editing one in the repo
takes effect at once.

Both paths recolour the same set: the bar, the compositor's borders, terminals,
notifications, rofi, the browser, Telegram, GTK and libadwaita apps (Nautilus
included), and Obsidian. Obsidian is coloured through a **snippet**, so whatever
theme you have selected there stays selected.

If you also run [Noctalia](https://github.com/noctalia-dev/noctalia-shell), turn
its GTK and Obsidian options off — otherwise two systems write the same colours
and which one wins is decided by file order rather than by intent.

## Keeping several machines in sync

The repo reaches `$HOME` by **copying**, so `git pull` alone changes nothing
outside `bin/` and `themes/`. `omvoid-update` closes that gap:

```bash
omvoid-update       # asks before replacing anything
omvoid-update -y    # unattended: reports differences, replaces nothing
```

It lists the files that differ from the repo and lets you pick per file. The old
version is kept as `<file>.bak.<epoch>` and the diff is printed. Files the system
owns after installation — your font choice, monitor layout, autostart, rclone
config, generated files — are never offered.

Edits happen on both sides, so there is a way back:

```bash
omvoid-refresh-config --capture mango/conf/windowrules.conf
```

That takes the live file into the repo. Without it, a tweak made in passing on a
live config dies at the next update. Paths may be given repo-relative
(`applications/imv.desktop`, `default/.bashrc`) or, for configs, relative to
`~/.config`.

To bring a machine that has never been synced up to date, run the installer first
so it picks up any new steps, then update:

```bash
cd ~/.local/share/omvoid && git pull
bash ~/.local/share/omvoid/install.sh
omvoid-update
```

## Migrations

The sync can deliver a file. It cannot remove one that is no longer in the repo,
move it, or repair something in place — `git pull` only knows about what exists.
That is what migrations are for.

```bash
omvoid-dev-add-migration "drop walker: removed from omvoid"
omvoid-migrate --pending
```

Each one runs once per machine and is remembered in
`~/.local/state/omvoid/migrations/`. `omvoid-update` runs pending ones for you.
A migration only helps if it is **committed and pushed** — it travels like any
other file in the repo.

## AI coding agents

Agent CLIs are pre-wired as lazy wrappers: the command is on your PATH from first
boot, weighs a couple of hundred bytes, and downloads the real tool the first time
you run it. `claude`, `agy`, `codex`, `opencode`, `crush`, `copilot`, `pi`, `gh`
and others are ready this way.

```bash
omvoid-mise-list                  # what is wrapped, and what has been downloaded
omvoid-mise-install <package>     # wrap another one
omvoid-update-mise                # update everything mise manages
```

A bar module shows how much of your subscription is used — the percentage of the
5-hour and weekly limits, time until they reset, and tokens by day and by model.
It appears only once there is real usage on the machine. Click it to refresh.

The authoritative percentages need a live sign-in, which only the terminal
`claude` refreshes; the token counts come from local transcripts and always work.

OMVOID also ships a **skill** describing itself, symlinked into the skill
directories of Claude Code, Codex, Antigravity and the generic `~/.agents/skills`.
Agents that read it know how this system is put together without being told.

## Adding your own things

**A theme.** Create `themes/<name>/` with `colors.json` (pywal format),
`icons.theme`, `chromium.theme` and a `backgrounds/` folder, then symlink it into
`~/.config/omvoid/themes/`.

**A program that is not packaged.** Drop the executable into
`install/apps/files/`. It is installed to `~/.local/bin` on fresh machines and
offered by `omvoid-update` on existing ones — no new install step needed.

**An install step.** Create `install/<group>/<name>.sh` and add
`run_step <group>/<name>.sh` to `install.sh`. Steps are *sourced*: never call
`exit` from one, it would kill the whole installer.

**A wrapped CLI.** Add a line to `install/development/mise.sh`.

## Where things live

| | |
|---|---|
| `~/.local/share/omvoid` | the repo, also `$OMVOID_PATH` |
| `~/.config/omvoid/current/theme` | symlink to the active theme |
| `~/.config/wallpaper` | wallpapers offered by `ALT+W` |
| `~/.cache/wal/` | generated colours; everything reads from here |
| `~/.local/state/omvoid/done/` | which install steps have run |
| `~/.local/state/omvoid/migrations/` | which migrations have run |
| `~/.local/state/omvoid/install.log` | the installer's log |
| `~/.cache/omvoid_wallpaper/` | wallpaper thumbnails and current-wallpaper state |

## Troubleshooting

**A step needs to run again.** Delete its marker and re-run the installer:

```bash
rm ~/.local/state/omvoid/done/development/mise.sh
```

**The bar is wrong after a config change.** `omvoid-reload-waybar`, or `SUPER+W`.

**Colours did not follow a theme change.** Almost always a missing reload rather
than a hardcoded colour — colours are never written into app configs by hand.

**A theme switch did nothing.** If `wal` fails, the switch stops on purpose and
notifies instead of reloading the compositor against a half-written cache.

**Something crashed and left nothing behind.** Core dumps are off by default on
Void, so there is nothing to look at afterwards. Enable them before you need them.
