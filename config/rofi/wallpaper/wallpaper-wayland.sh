#!/bin/bash

# The wallpaper picker — bound to ALT+W.
#
# Shows every wallpaper as a rofi grid of thumbnails, plus two entries at the
# top: pick one at random, or jump to the light/dark switcher without changing
# the picture. Deriving the palette and reloading everything is
# omvoid-theme-apply's job.

set -uo pipefail

WALLPAPER_DIR="$HOME/.config/wallpaper"
CACHE_DIR="$HOME/.cache/omvoid_wallpaper"
THEMES_DIR="$HOME/.config/rofi/wallpaper/themes"
ROFI_DIR="$HOME/.config/rofi"

# A second press of the keybinding closes the menu instead of stacking another.
if pidof rofi >/dev/null; then
  pkill rofi
  exit 0
fi

omvoid-wallpaper-thumbnails

mapfile -t pics < <(find -L "$WALLPAPER_DIR" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) | sort)

if ((${#pics[@]} == 0)); then
  rofi -e "No wallpapers in $WALLPAPER_DIR"
  exit 1
fi

theme_switch_entry="🎨 Switch Theme"
random_entry="[${#pics[@]}] Random"

menu() {
  printf '%s\n' "$theme_switch_entry"
  printf '%s\n' "$random_entry"
  local pic relative thumb
  for pic in "${pics[@]}"; do
    # GIFs are listed without an icon: the thumbnailer skips them, so pointing
    # rofi at a missing file would leave a blank tile.
    if [[ $pic == *.gif ]]; then
      printf '%s\n' "$(basename "$pic")"
    else
      relative="${pic#"$WALLPAPER_DIR"/}"
      thumb="$CACHE_DIR/thumbnails/${relative%.*}.png"
      printf '%s\x00icon\x1f%s\n' "$(basename "$pic")" "$thumb"
    fi
  done
}

choice=$(menu | rofi -show -dmenu -i -theme "$THEMES_DIR/wallpaper-select.rasi")
[[ -n $choice ]] || exit 0

case "$choice" in
"$theme_switch_entry")
  exec "$HOME/.config/rofi/wallpaper/wallpaper-switch-theme-wayland.sh"
  ;;
"$random_entry")
  selected="${pics[RANDOM % ${#pics[@]}]}"
  ;;
*)
  for pic in "${pics[@]}"; do
    [[ $(basename "$pic") == "$choice" ]] && { selected="$pic"; break; }
  done
  ;;
esac

if [[ -z ${selected:-} ]]; then
  rofi -e "Image not found: $choice"
  exit 1
fi

# Dark or light is asked after the picture, so the same wallpaper can be used
# either way without going back to the grid.
mode_choice=$(echo -e "Dark Mode\0icon\x1f${THEMES_DIR}/black.png\nLight Mode\0icon\x1f${THEMES_DIR}/white.png" | rofi -dmenu -p "Select Mode" -theme "${ROFI_DIR}/menu-style-minimal.rasi")
[[ -n $mode_choice ]] || exit 0

if [[ $mode_choice == "Light Mode" ]]; then
  mode="--light"
else
  mode="--dark"
fi

exec omvoid-theme-apply --image "$selected" "$mode"
