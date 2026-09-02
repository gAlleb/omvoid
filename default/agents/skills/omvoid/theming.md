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

## Gotchas

- Colours are **never** written by hand into app configs. If an app looks wrong
  after a theme change, the fix is almost always a missing reload in the fan-out,
  not a hardcoded colour.
- `wal -c` (clear cache) is called before `wal` in both paths. Keep it.
- The user's visual judgement is the only test that matters here. Screenshots
  and colour values do not reach the agent — describe the change and ask.
