#!/usr/bin/env bash

# Wallpapers Path
CACHE_DIR=$HOME/.cache/rofi_wallpaper_picker
CACHE_DIR2=$HOME/.cache/wallpaper_changer
WALLPAPER_DIR="$HOME/.config/wallpaper"
themesDir="$HOME/.config/rofi/wallpaper/themes"
CURRENT_WALLPAPER_PATH_FILE="${CACHE_DIR}/current_wallpaper_path"
CURRENT_THEME_FILE="${STATE_DIR}/current_theme"

if [ ! -d "${CACHE_DIR}" ] ; then
    mkdir -p "${CACHE_DIR}"
fi

if [ ! -d "${CACHE_DIR2}" ] ; then
    mkdir -p "${CACHE_DIR2}"
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

    wal -c

    # Generate the new color scheme using wal with the determined flag
    wal ${wal_flags} -i ${selected_wallpaper}

    # Update other applications
    # swww img --transition-type any --transition-angle 45 "${selected_wallpaper}"
    # pywalfox update
    #sh $HOME/.config/hypr/scripts/wallpaper_changer.sh ${selected_wallpaper}
    echo "\$wallpaper = ${selected_wallpaper}" > $CACHE_DIR2/wallpaper-hyprland.conf
    # pkill -SIGUSR2 waybar
    # swaync-client -rs
    echo "\$wallpaper_thumbnail = $selected_thumbnail_path" > ~/.cache/wallpaper_thumbnail
    echo "inputbar { background-image: url(\"$selected_thumbnail_path\", width); }" > ~/.cache/wallpaper_thumbnail.rasi
    # $HOME/.config/nwg-dock-hyprland/reload.sh &
    # $HOME/.config/swayosd/launch.sh &

    echo "${selected_wallpaper}" > "${CURRENT_WALLPAPER_PATH_FILE}"

    convert "${selected_wallpaper}" /home/stefan/.config/bg.jpg

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

