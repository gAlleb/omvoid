#!/bin/bash

# Хук Noctalia: она зовёт этот скрипт, когда сама меняет обои. Наше дело --
# вывести из картинки палитру и раздать её всем остальным.
#
# Обои всё равно ставятся через awww, хотя Noctalia рисует свои: её обои видны
# только пока работает её оболочка. Переключишься на waybar -- Noctalia уходит,
# и проявляется то, что лежит под ней. Не поставить их значит увидеть прошлые.
#
# А вот сообщать Noctalia о смене не надо: она нас этим хуком и вызвала,
# получилась бы петля -- отсюда --no-noctalia.

set -uo pipefail

wallpaper="${NOCTALIA_WALLPAPER_PATH:-${1:-}}"

if [[ -z $wallpaper || ! -f $wallpaper ]]; then
  echo "wallpaper-noctalia: обои не найдены" >&2
  exit 1
fi

# Режим Noctalia сообщает переменной; если не сообщила -- берём тот, что стоит
# в системе сейчас, чтобы не переключить светлую на тёмную вслепую.
mode="--dark"
if [[ ${NOCTALIA_THEME_MODE:-} == "light" ]]; then
  mode="--light"
elif [[ -z ${NOCTALIA_THEME_MODE:-} ]] && omvoid-cmd-present gsettings; then
  [[ $(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null) == *prefer-light* ]] && mode="--light"
fi

exec omvoid-theme-apply --image "$wallpaper" "$mode" --no-noctalia
