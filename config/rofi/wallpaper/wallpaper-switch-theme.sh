#!/usr/bin/env bash

# Paths (should match your main wallpaper script)
CACHE_DIR="$HOME/.cache/omvoid_wallpaper"
WALLPAPER_DIR="$HOME/.config/wallpaper"
THEMES_DIR="$HOME/.config/rofi/wallpaper/themes"
CURRENT_WALLPAPER_PATH_FILE="${CACHE_DIR}/current_wallpaper_path"

# --- Main Logic ---

# 1. Check if a current wallpaper has been set before
if [ ! -f "${CURRENT_WALLPAPER_PATH_FILE}" ]; then
    rofi -e "No current wallpaper set. Please run the wallpaper picker first."
    exit 1
fi

# 2. Read the path of the current wallpaper
current_wallpaper=$(cat "${CURRENT_WALLPAPER_PATH_FILE}")

# 3. Check if the saved path is empty or the file doesn't exist anymore
if [ -z "${current_wallpaper}" ] || [ ! -f "${current_wallpaper}" ]; then
    rofi -e "Saved wallpaper not found. Please run the wallpaper picker again."
    exit 1
fi

# 4. Show the Rofi menu for Light/Dark mode selection
mode_choice=$(echo -e "Dark Mode\0icon\x1f${THEMES_DIR}/black.png\nLight Mode\0icon\x1f${THEMES_DIR}/white.png" | rofi -dmenu -p "Switch Mode" -theme "${THEMES_DIR}/dark-light-mode-select.rasi")

# 5. Exit if the user cancelled
if [[ -z "$mode_choice" ]]; then
    exit 0
fi

# 6. Determine the correct `wal` flag based on the choice
local wal_flags=""
if [ "$mode_choice" = "Light Mode" ]; then
    wal_flags="-l -i ${current_wallpaper}"
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
    kvantummanager --set WhiteSur-opaque
else
    wal_flags="-i ${current_wallpaper}"
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-grey-dark"
    kvantummanager --set WhiteSur-opaqueDark
fi

wal -c

# Generate the new color scheme using wal with the determined flag
#wal ${wal_flags} -i ${selected_wallpaper}
wal ${wal_flags} 

pywalfox update
pkill -SIGUSR2 waybar
swaync-client -rs
$HOME/.config/nwg-dock-hyprland/reload.sh &
$HOME/.config/swayosd/launch.sh &

exit 0
