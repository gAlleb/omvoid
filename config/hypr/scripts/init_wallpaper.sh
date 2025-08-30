#!/usr/bin/env bash

# Wallpapers Path
CACHE_DIR="$HOME/.cache/omvoid_wallpaper"
WALLPAPER_DIR="$HOME/.config/wallpaper"
THEMES_DIR="$HOME/.config/rofi/wallpaper/themes"
CURRENT_WALLPAPER_PATH_FILE="${CACHE_DIR}/current_wallpaper_path"

if [ ! -d "${CACHE_DIR}" ] ; then
    mkdir -p "${CACHE_DIR}"
fi

find -L "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.webp \) | while read -r wallpaper_path; do
    # Get the relative path to maintain subdirectory structure in the cache
    relative_path="${wallpaper_path#${WALLPAPER_DIR}/}"
    thumbnail_path="${CACHE_DIR}/${relative_path%.*}.png"

    # Create the directory in the cache if it doesn't exist
    if [ ! -d "$(dirname "${thumbnail_path}")" ]; then
        mkdir -p "$(dirname "${thumbnail_path}")"
    fi

    # If the thumbnail doesn't exist, create it
    if [ ! -f "${thumbnail_path}" ]; then
        # Using magick to create a small thumbnail
        magick "${wallpaper_path}" -thumbnail '320x180>' "${thumbnail_path}"
    fi
done

# Retrieve image files as a list
PICS=($(find -L "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif  -o -iname \*.webp \) | sort ))

# Use date variable to increase randomness
randomNumber=$(( ($(date +%s) + RANDOM) + $$ ))
randomPicture="${PICS[$(( randomNumber % ${#PICS[@]} ))]}"
randomChoice="[${#PICS[@]}] Random"

executeCommand() {
    # The selected wallpaper path is passed as the first argument ($1)
    local selected_wallpaper="$1"
    local relative_path="${selected_wallpaper#${WALLPAPER_DIR}/}"
    local selected_thumbnail_path="${CACHE_DIR}/${relative_path%.*}.png"

    ~/.local/bin/wal -c

    # Generate the new color scheme using wal with the determined flag
    ~/.local/bin/wal ${wal_flags} -i ${selected_wallpaper}

    # Update other applications
    echo "\$wallpaper = ${selected_wallpaper}" > $CACHE_DIR/wallpaper-hyprland.conf
    echo "\$wallpaper_thumbnail = $selected_thumbnail_path" > ${CACHE_DIR}/wallpaper_thumbnail
    echo "inputbar { background-image: url(\"$selected_thumbnail_path\", width); }" > ${CACHE_DIR}/wallpaper_thumbnail.rasi
    echo "${selected_wallpaper}" > "${CURRENT_WALLPAPER_PATH_FILE}"
    magick "${selected_wallpaper}" ~/.config/bg.jpg
}

# Execution
main() {
    executeCommand "${randomPicture}"
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

main

