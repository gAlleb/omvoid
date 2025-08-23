#!/usr/bin/env bash

    THEMES_DIR=$HOME/.config/rofi/wallpaper/themes
    CACHE_DIR=$HOME/.cache/omvoid_wallpaper 
    CURRENT_WALLPAPER_PATH_FILE="${CACHE_DIR}/current_wallpaper_path"
   
    selected_wallpaper=$1
    
    mode_choice=$(echo -e "Dark Mode\0icon\x1f${THEMES_DIR}/black.png\nLight Mode\0icon\x1f${THEMES_DIR}/white.png" | rofi -dmenu -p "Select Mode" -theme "${THEMES_DIR}/dark-light-mode-select.rasi")

    if [[ -z $mode_choice ]]; then
        exit 0
    fi

    local wal_flags=""
    if [ "$mode_choice" = "Light Mode" ]; then
        wal_flags="-l"
    fi

    magick "${selected_wallpaper}" ~/.config/bg.jpg

    wal -c

    wal ${wal_flags} -i ~/.config/bg.jpg
    swww img --transition-type any --transition-angle 45 "${selected_wallpaper}"
    pywalfox update
    echo "\$wallpaper = ${selected_wallpaper}" > $CACHE_DIR/wallpaper-hyprland.conf
    pkill -SIGUSR2 waybar
    swaync-client -rs
    echo "\$wallpaper_thumbnail = $selected_thumbnail_path" > $CACHE_DIR/wallpaper_thumbnail
    echo "inputbar { background-image: url(\"$selected_thumbnail_path\", width); }" > $CACHE_DIR/wallpaper_thumbnail.rasi
    $HOME/.config/nwg-dock-hyprland/reload.sh &
    $HOME/.config/swayosd/launch.sh &
    echo "${selected_wallpaper}" > "${CURRENT_WALLPAPER_PATH_FILE}"
