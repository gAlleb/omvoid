#!/bin/bash
#grim -g "$(slurp -d -w 0 -b "#CCCCFF4D")" -t png - | wl-copy -t image/png && wl-paste > ~/Pictures/$(date +%Y%m%d%H%m%S)_grim.png

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="$HOME/Pictures"

if [[ ! -d "$OUTPUT_DIR" ]]; then
  notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
  exit 1
fi

grim -g "$(slurp -d -w 0 -b "#CCCCFF4D")" -t png - | satty --filename - \
    --output-filename "$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png" \
    --early-exit \
    --actions-on-enter save-to-clipboard \
    --save-after-copy \
    --copy-command 'wl-copy'

#[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
#OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"
#
#if [[ ! -d "$OUTPUT_DIR" ]]; then
#  notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
#  exit 1
#fi
#
#pkill slurp || hyprshot -m ${1:-region} --raw |
#  satty --filename - \
#    --output-filename "$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png" \
#    --early-exit \
#    --actions-on-enter save-to-clipboard \
#    --save-after-copy \
#    --copy-command 'wl-copy'
