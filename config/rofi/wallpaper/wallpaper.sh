#!/usr/bin/env bash
## /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# This script for selecting wallpapers (SUPER W)

# Wallpapers Path
CACHE_DIR=$HOME/.cache/rofi_wallpaper_picker
WALLPAPER_DIR="$HOME/.config/wallpaper"
themesDir="$HOME/.config/rofi/themes"

if [ ! -d "${CACHE_DIR}" ] ; then
    mkdir -p "${CACHE_DIR}"
fi

#==============================================================================
# NEW CACHING SECTION
#==============================================================================
# Create thumbnails for all wallpapers if they don't exist in the cache.
# This makes Rofi load much faster.
# Note: Requires 'imagemagick' to be installed.
find -L "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.webp \) | while read -r wallpaper_path; do
    # Get the relative path to maintain subdirectory structure in the cache
    relative_path="${wallpaper_path#${WALLPAPER_DIR}/}"
    thumbnail_path="${CACHE_DIR}/${relative_path}"

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
#==============================================================================
# END OF NEW CACHING SECTION
#==============================================================================


# Retrieve image files as a list
PICS=($(find -L "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif  -o -iname \*.webp \) | sort ))

# Use date variable to increase randomness
randomNumber=$(( ($(date +%s) + RANDOM) + $$ ))
randomPicture="${PICS[$(( randomNumber % ${#PICS[@]} ))]}"
randomChoice="[${#PICS[@]}] Random"

# Rofi command
rofiCommand="rofi -show -dmenu -DPI 1.6 -i -p Wallpepers! -theme ${themesDir}/wallpaper-select.rasi"

# Execute command according the wallpaper manager
#executeCommand() {

#convert "$1" /home/stefan/.config/bg.jpg
#wal -c
#wal -i /home/stefan/.config/bg.jpg
#pywalfox update
##sh $HOME/.config/hypr/scripts/wallpaper_changer.sh $1
#swww img --transition-type wipe --transition-angle 45 $1
#pkill -SIGUSR2 waybar
#swaync-client -rs
#}
#==============================================================================
# MODIFIED SECTION
#==============================================================================
# Execute command according the wallpaper manager
executeCommand() {
    # The selected wallpaper path is passed as the first argument ($1)
    local selected_wallpaper="$1"

    # --- New Rofi menu for Light/Dark mode selection ---
    # We use `echo` to create the menu entries and pipe them to rofi in dmenu mode.
    # We also add a prompt (-p) to make it clear what the user is choosing.
    #mode_choice=$(echo -e "Dark Mode\nLight Mode" | rofi -dmenu -p "Select Mode" -theme "${themesDir}/dark-light-mode-select.rasi")

    mode_choice=$(echo -e "Dark Mode\0icon\x1f${themesDir}/black.png\nLight Mode\0icon\x1f${themesDir}/white.png" | rofi -dmenu -p "Select Mode" -theme "${themesDir}/dark-light-mode-select.rasi")

    # If the user cancels the mode selection (e.g., presses Esc), exit gracefully.
    if [[ -z "$mode_choice" ]]; then
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
    xwallpaper --zoom $HOME/.config/bg.jpg
    xrdb merge /home/stefan/.cache/wal/colors-dwm-xresources
    xdotool key alt+shift+F5
    xrdb merge ~/.Xresources
    pywalfox update
    sh $HOME/.config/hypr/scripts/wallpaper_changer.sh ${selected_wallpaper}
}
#==============================================================================
# END OF MODIFIED SECTION
#==============================================================================
# Show the images
menu() {

  printf "$randomChoice\n"

  for i in "${!PICS[@]}"; do
  
    # If not *.gif, display with cached thumbnail
    if [[ ! "${PICS[$i]}" == *.gif ]]; then
      relative_path="${PICS[$i]#${WALLPAPER_DIR}/}"
      thumbnail_path="${CACHE_DIR}/${relative_path}"
      printf "$(basename "${PICS[$i]}")\x00icon\x1f${thumbnail_path}\n"
    else
    # Displaying .gif to indicate animated images (without an icon)
      printf "$(basename "${PICS[$i]}")\n"
    fi
  done
}

# Execution
main() {
  choice=$(menu | ${rofiCommand})

  # No choice case
  if [[ -z $choice ]]; then
    exit 0
  fi

  # Random choice case
  if [ "$choice" = "$randomChoice" ]; then
    executeCommand "${randomPicture}"
    return 0
  fi

  # Find the selected file
  for file in "${PICS[@]}"; do
  # Getting the file by matching the full filename
    if [[ "$(basename "$file")" = "$choice" ]]; then
      selectedFile="$file"
      break
    fi
  done

  # Check the file and execute
  if [[ -n "$selectedFile" ]]; then
    executeCommand "${selectedFile}"
    return 0
  else
    echo "Image not found."
    exit 1
  fi

}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

main