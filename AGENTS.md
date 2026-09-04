# Working on OMVOID

OMVOID is a personal Void Linux distribution: this repository installs and
configures an entire desktop, then stays on the machine and keeps owning those
configs. It lives at `~/.local/share/omvoid`, also exported as `$OMVOID_PATH`.

It borrows conventions from [Omarchy](https://omarchy.org/), but targets
**Void Linux** (xbps, runit) and **mango** — a dwl-based Wayland compositor
driven by `mmsg`. Not Arch, not Hyprland. Hyprland variants of some configs still
sit in the tree; they are not the running system.

## How code here reaches the machine

Different directories deploy differently, and getting this wrong means a change
that works today and vanishes on the next install:

| | how it reaches `$HOME` | consequence |
|---|---|---|
| `bin/` | already on PATH from the repo | edits are live immediately |
| `config/` | `cp -R config/* ~/.config/` in `install/config/config.sh` | **edit both**, or edit the repo and re-copy |
| `themes/` | symlinked into `~/.config/omvoid/themes/` | edits are live immediately |
| `default/` | copied file by file in `install/config/config.sh` (`.bashrc`, `.bash_profile`, `.gtkrc-2.0`, `gnupg/`) | **edit both**; `default/xcompose` is the exception — it is included by path, so it is live |
| `default/agents/skills/` | symlinked by `omvoid-link-skills` | edits are live immediately |

## Task guides

Deeper instructions live in `default/agents/skills/omvoid/`. Read the matching
one before starting — they are written for this system specifically and are not
duplicated here:

- [`install-scripts.md`](default/agents/skills/omvoid/install-scripts.md) — adding or editing anything under `install/`
- [`updating.md`](default/agents/skills/omvoid/updating.md) — reaching machines that are already installed: the file sync and migrations
- [`theming.md`](default/agents/skills/omvoid/theming.md) — themes, wallpapers, and the pywal fan-out
- [`mise-stubs.md`](default/agents/skills/omvoid/mise-stubs.md) — lazy CLI wrappers backed by mise
- [`agent-usage.md`](default/agents/skills/omvoid/agent-usage.md) — AI usage collectors and the waybar module

Those same files are symlinked into `~/.claude/skills/omvoid` and the equivalent
directories for other agents, so they also apply when working outside this repo.

## Style

Follow the file you are editing. Across the tree the majority conventions are:

- `#!/bin/bash`, two-space indentation, no tabs
- `[[ ]]` for string and file tests
- scripts under `install/` are `source`d — no shebang needed, and **never** call
  `exit` from one, it kills the whole installer
- comments explain *why*, not what, and are written in **English**. Some older
  scripts still carry Russian comments; translate them when you touch the file
  rather than adding more.

## Naming

Every executable is `bin/omvoid-<verb>-<noun>`, no extension, `chmod +x`.
Existing families to follow: `omvoid-theme-*`, `omvoid-cmd-*`, `omvoid-launch-*`,
`omvoid-mise-*`, `omvoid-agent-usage-*`.

State goes to `~/.local/state/omvoid/`, caches to `~/.cache/omvoid/` and
`~/.cache/omvoid_wallpaper/`. Never write generated files back into the repo.

## Verifying a change

There is no test suite. Check what can be checked mechanically, then hand the
rest to the user — the screen is not visible from here:

```bash
bash -n <script>                       # every shell file touched
python3 -c "import ast; ast.parse(open('<file>').read())"   # python files
omvoid-reload-waybar                   # waybar config or style
rm ~/.local/state/omvoid/done/<group>/<step>.sh   # to re-run one install step
```

Anything with a visual effect — bar layout, colours, spacing, window rules —
must be described to the user and confirmed by them. Do not declare it working
from the code alone.

## Care

This is one person's daily system, tuned by hand over years. Negative margins,
commented-out lines and near-duplicate configs are usually deliberate, not
mistakes waiting to be cleaned up. Say what you would change and why, then wait.

Do not commit unless asked.
