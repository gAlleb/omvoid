#!/bin/bash

# Меняет только светлую или тёмную, оставляя текущие обои.
#
# Раньше этот скрипт нёс свою копию веера, и в ней не хватало трёх вещей:
# перезагрузки конфига композитора, симлинка dunstrc и wal-telegram. Поэтому
# после переключения рамки окон, уведомления и Telegram оставались в прежних
# цветах, а всё остальное перекрашивалось.

set -uo pipefail

CACHE_DIR="$HOME/.cache/omvoid_wallpaper"
THEMES_DIR="$HOME/.config/rofi/wallpaper/themes"
ROFI_DIR="$HOME/.config/rofi"
CURRENT_WALLPAPER_PATH_FILE="$CACHE_DIR/current_wallpaper_path"

if [[ ! -f $CURRENT_WALLPAPER_PATH_FILE ]]; then
  rofi -e "No current wallpaper set. Please run the wallpaper picker first."
  exit 1
fi

current_wallpaper=$(<"$CURRENT_WALLPAPER_PATH_FILE")

if [[ -z $current_wallpaper || ! -f $current_wallpaper ]]; then
  rofi -e "Saved wallpaper not found. Please run the wallpaper picker again."
  exit 1
fi

# Строка с \0icon\x1f -- формат rofi для пунктов с картинками, оставлена дословно.
mode_choice=$(echo -e "Dark Mode\0icon\x1f${THEMES_DIR}/black.png\nLight Mode\0icon\x1f${THEMES_DIR}/white.png" | rofi -dmenu -p "Select Mode" -theme "${ROFI_DIR}/menu-style-minimal.rasi")

# Отменили выбор -- ничего не делаем.
[[ -n $mode_choice ]] || exit 0

if [[ $mode_choice == "Light Mode" ]]; then
  mode="--light"
else
  mode="--dark"
fi

exec omvoid-theme-apply --image "$current_wallpaper" "$mode"
