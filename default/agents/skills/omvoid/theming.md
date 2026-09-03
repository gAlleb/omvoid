# Theming, colours and wallpapers

**pywal is the hub.** Whatever changes the look, it ends by running `wal`, which
writes `~/.cache/wal/`. Consumers either import from there or get poked to
reload. Waybar, for instance, starts its stylesheet with
`@import "../../.cache/wal/colors-waybar.css"` and is then sent `SIGUSR2`.

There are two ways in, and they converge on the same fan-out.

## Path A — the wallpaper picker (used most often)

`ALT+W` → `~/.config/rofi/wallpaper/wallpaper-hypr.sh`
(bound in `config/mango/conf/keybindings.conf:145`).

Despite the `-hypr` suffix this is the **mango/Wayland** path — the name is a
leftover. `wallpaper.sh` next to it is the older X11/dwm variant; do not edit the
wrong one. `wallpaper-noctalia.sh` is the entry point used when Noctalia drives
the wallpaper instead.

What it does: builds thumbnails of `~/.config/wallpaper/*` into
`~/.cache/omvoid_wallpaper/thumbnails/`, shows a rofi grid, asks Dark or Light,
then runs `wal -i <image>` (`-l -i` for light) and the fan-out below. The
`🎨 Switch Theme` entry re-runs only the light/dark half via
`wallpaper-switch-theme-hypr.sh`, keeping the current wallpaper.

Light/dark also sets GTK and Qt directly, outside pywal:
`gsettings set org.gnome.desktop.interface gtk-theme|color-scheme|icon-theme`
(WhiteSur variants) and `kvantummanager --set WhiteSur-opaque[Dark]`.

## Path B — curated themes

`omvoid-theme-set <name>`, `omvoid-theme-next`, `omvoid-theme-list`,
`omvoid-theme-current`.

Themes live in `themes/<name>/` in the repo and are **symlinked** into
`~/.config/omvoid/themes/` by `install/desktop/theme.sh` — so editing a theme in
the repo takes effect with no copy step. Selection is a symlink:
`~/.config/omvoid/current/theme` → the chosen theme,
`~/.config/omvoid/current/background` → one file inside its `backgrounds/`.

`omvoid-theme-set` runs `wal --theme <theme>/colors.json` instead of deriving
colours from an image, then the same fan-out, then `omvoid-theme-bg-next` to pick
the background.

### Adding a theme

```
themes/<name>/
  colors.json     # pywal format: special.{background,foreground,cursor} + colors.color0..15
  icons.theme     # one line, e.g. WhiteSur-dark
  chromium.theme  # one line
  backgrounds/    # one or more images
```

Then `ln -nfs ~/.local/share/omvoid/themes/<name> ~/.config/omvoid/themes/`
(or re-run the loop at the end of `install/desktop/theme.sh`).

## The fan-out

Both paths poke roughly the same consumers. When adding one, add it to **both**
`wallpaper-hypr.sh` and `omvoid-theme-set` — they are duplicated by hand and
drift easily.

| Consumer | How it is refreshed |
|---|---|
| wallpaper | `awww img --transition-type any --transition-angle 45 <path>` |
| mango | `mmsg dispatch reload_config` |
| waybar | `pkill -SIGUSR2 waybar` (or `omvoid-reload-waybar`) |
| notifications | `swaync-client -rs`, `makoctl reload`, dunst via `~/.cache/wal/dunstrc` symlink then killed |
| browser | `pywalfox update`, `omvoid-theme-set-browser` |
| Telegram | `wal-telegram --wal` |
| rofi | thumbnail written to `~/.cache/omvoid_wallpaper/wallpaper_thumbnail.rasi`, imported by the `.rasi` menus |
| lock screen | `~/.cache/omvoid_wallpaper/wallpaper-hyprland.conf` |
| GTK/Qt | `gsettings`, `kvantummanager` |
| Noctalia | `noctalia msg wallpaper-set <path>` — only when `pgrep -x noctalia` succeeds |
| misc | `~/.config/bg.jpg` written with `magick`, nwg-dock and swayosd relaunch scripts |

`~/.cache/omvoid_wallpaper/current_wallpaper_path` records the active wallpaper;
`wallpaper-switch-theme-hypr.sh` reads it and fails loudly if it is missing.

## GTK, libadwaita and Obsidian

Nautilus and everything else on libadwaita **ignore GTK themes entirely**. The
only thing they honour is `@define-color` overrides in `gtk.css`. So the colours
are shipped as a separate file next to it and pulled in with an `@import`, which
`omvoid-theme-set-gtk` appends as the **last** line — in CSS the last declaration
wins, and Noctalia may have its own `@import` in the same files.

Obsidian gets a **snippet**, not a theme: `<vault>/.obsidian/snippets/omvoid.css`
plus one entry in `enabledCssSnippets`. A theme would force the user off whatever
theme they picked; a snippet layers colours on top of it. Vault paths come from
`~/.config/obsidian/obsidian.json`, never hardcoded.

`appearance.json` is written **once**, only when the snippet is not yet enabled.
Obsidian keeps that file open and rewrites it from its own memory; writing to it
on every theme change once wiped five of the user's enabled snippets. After the
first time only the CSS changes, and Obsidian hot-reloads it without a fight.

### The tonal ramp

Do not build surfaces from `{background}`: in pywal palettes `color0` usually
equals it, so every surface collapses into the same flat dark and the theme's hue
disappears. Build the ramp from `color1` instead, in `darken` steps, and take the
accent from a vivid entry:

```
{color1.saturate(18).darken(62)}   window background
{color1.saturate(18).darken(45)}   headerbars, cards, sidebars
{color1.saturate(18).lighten(10)}  borders
{color5}                           accent
```

### pywal16 specifics

The fork behaves differently from stock pywal, and each difference has bitten:

- **Percentages must be integers.** `lighten(0.2)` becomes 2%, not 20% — the
  argument is run through `re.sub(r"[\D\.]", "", …)`, which strips the dot.
- **`saturate(N)` sets saturation, it does not add.** The same template gives
  0.26 on every theme, so a palette that is already vivid can come out flatter.
- **Templates are parsed by regex, not `str.format()`.** A marker needs both
  braces on one line, so a CSS block brace at the end of a line passes through
  untouched. `{{` and `}}` still work and are unescaped at the end — prefer them,
  as `base46-dark.lua` does.
- **A broken template is skipped, not fatal.** pywal logs the error and moves on
  to the next file.

## When wal fails

Every branch checks `wal`'s exit status before reloading anything. This matters
because `mango/conf/config.conf` sources `~/.cache/wal/colors-mango.conf` on its
first line, and `wal -c` deletes that cache before regenerating it. Reloading the
compositor against a half-written cache is how a theme switch can take the whole
session down. If `wal` fails, the branch stops and notifies instead.

## Gotchas

- Colours are **never** written by hand into app configs. If an app looks wrong
  after a theme change, the fix is almost always a missing reload in the fan-out,
  not a hardcoded colour.
- `wal -c` (clear cache) is called before `wal` in both paths. Keep it.
- The user's visual judgement is the only test that matters here. Screenshots
  and colour values do not reach the agent — describe the change and ask.
