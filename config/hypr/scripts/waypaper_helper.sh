#!/usr/bin/env bash

    themesDir=$HOME/.config/rofi/wallpaper/themes
    CACHE_DIR=$HOME/.cache/wallpaper_changer
    # The selected wallpaper path is passed as the first argument ($1)
    selected_wallpaper=$1
    
    # --- New Rofi menu for Light/Dark mode selection ---
    # We use `echo` to create the menu entries and pipe them to rofi in dmenu mode.
    # We also add a prompt (-p) to make it clear what the user is choosing.
    #mode_choice=$(echo -e "Dark Mode\nLight Mode" | rofi -dmenu -p "Select Mode" -theme "${themesDir}/dark-light-mode-select.rasi")

    mode_choice=$(echo -e "Dark Mode\0icon\x1f${themesDir}/black.png\nLight Mode\0icon\x1f${themesDir}/white.png" | rofi -dmenu -p "Select Mode" -theme "${themesDir}/dark-light-mode-select.rasi")

    # If the user cancels the mode selection (e.g., presses Esc), exit gracefully.
    if [[ -z $mode_choice ]]; then
        exit 0
    fi

    # --- Determine the correct `wal` flag based on the choice ---
    local wal_flags=""
    if [ "$mode_choice" = "Light Mode" ]; then
        wal_flags="-l"
    fi
    # If "Dark Mode" is chosen, wal_flags remains empty, which is the default behavior.

    # --- Execute all the commands ---
    # 1. Convert the image to a standard name/location (optional but good practice)
    convert "${selected_wallpaper}" /home/stefan/.config/bg.jpg

    # 2. Clear the old wal cache
    wal -c

    # 3. Generate the new color scheme using wal with the determined flag
    wal ${wal_flags} -i /home/stefan/.config/bg.jpg

    # 4. Update other applications
    pywalfox update
    echo "\$wallpaper = ${selected_wallpaper}" > $CACHE_DIR/wallpaper-hyprland.conf
    pkill -SIGUSR2 waybar
    swaync-client -rs
