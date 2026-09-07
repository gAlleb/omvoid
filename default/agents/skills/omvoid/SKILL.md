---
name: omvoid
description: >
  REQUIRED when working on the OMVOID Void Linux distribution — its repository at
  ~/.local/share/omvoid, or the configs it deploys to ~/.config. Use when adding or
  editing install steps, omvoid-* scripts, themes, wallpapers, waybar modules, mango
  (window manager) config, mise tool wrappers, or agent usage collectors.
  Triggers: omvoid, Void Linux, xbps, runit, mango, mmsg, waybar, pywal, wal, swww/awww,
  rofi wallpaper picker, theme, background, install.sh, run_step, omvoid-mise-install,
  omvoid-agent-usage, TUI.float, noctalia.
---

# OMVOID

OMVOID is a personal Void Linux distribution: a git repository that installs and
configures a whole desktop. It is not a package — it is a checkout that stays on
the machine and keeps owning its configs.

**Repository:** `~/.local/share/omvoid`, also exported as `$OMVOID_PATH`.

Do not confuse it with Omarchy, the Arch/Hyprland distribution some conventions
were borrowed from. OMVOID targets **Void Linux** (xbps, runit) and **mango**
(a dwl-based Wayland compositor driven by `mmsg`), not Arch and not Hyprland.
Hyprland variants of some configs still exist in the tree but are not the
system in use.

## Layout

| Path | What it is |
|---|---|
| `bin/` | every executable, all named `omvoid-*`. On PATH via `default/.bash_profile`. |
| `install.sh` | the installer: a list of `run_step` calls |
| `install/<group>/<step>.sh` | one install step each, `source`d by `install.sh` |
| `config/` | copied wholesale to `~/.config/` by `install/config/config.sh` |
| `themes/<name>/` | colour schemes: `colors.json`, `icons.theme`, `chromium.theme`, `backgrounds/` |
| `default/` | dotfiles deployed to `$HOME` (`.bashrc`, `.bash_profile`, …) |
| `default/agents/skills/` | these skills, symlinked into agent skill directories |
| `srcpkgs/` | xbps source packages built locally for things missing from Void repos |

State that must not live in the repo goes to `~/.local/state/omvoid/`.
Caches go to `~/.cache/omvoid/` and `~/.cache/omvoid_wallpaper/`.

## Topic guides

Read the matching guide before touching one of these areas:

- [`install-scripts.md`](install-scripts.md) — adding or editing an install step
- [`updating.md`](updating.md) — how a change reaches an installed machine: the file sync, its exclusions, and migrations
- [`theming.md`](theming.md) — themes, wallpapers, and the pywal fan-out
- [`mise-stubs.md`](mise-stubs.md) — lazy CLI wrappers backed by mise
- [`agent-usage.md`](agent-usage.md) — AI agent usage collectors and the waybar module
- [`iso.md`](iso.md) — the installation image, and writing install steps that survive a chroot

## Conventions that apply everywhere

**Every executable is `bin/omvoid-<verb>-<noun>`**, no extension, `chmod +x`.
Existing families: `omvoid-theme-*`, `omvoid-cmd-*`, `omvoid-launch-*`,
`omvoid-mise-*`, `omvoid-agent-usage-*`. Follow the nearest family when adding one.

**The repo is the source; `~/.config` is a copy.** `install/config/config.sh`
does `cp -R config/* ~/.config/`. Editing a live config under `~/.config` alone
means the change is lost on the next install and absent on a fresh machine —
change both, or change the repo and re-copy. Themes are the exception: they are
**symlinked**, so repo edits take effect immediately.

**Void, not Arch.** Packages come from `xbps-install -y`, never pacman/yay.
System services are runit: `sudo ln -s /etc/sv/<name> /var/service`. User
services live in `~/.config/service` (`SVDIR`), started by `runsvdir`.
When something is missing from Void repos, it is either built from `srcpkgs/`
or fetched from GitHub releases (see `install/development/mihomo.sh` for the
pattern: resolve the asset URL, verify the arch, install by hand).

**Terminal UIs open floating.** Launch them through
`omvoid-launch-tui <command>` — it sets `--class=TUI.float`, and
`config/mango/conf/windowrules.conf:15` floats and centres that appid at
800×600. Do not spawn a terminal directly for a TUI.

**Ask before restructuring.** This is one person's system, tuned by hand over
time. Odd-looking negative margins, commented-out lines and duplicated configs
are usually deliberate. Explain what you would change and why before changing it.
