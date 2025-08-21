#!/bin/bash
CACHE_DIR=$HOME/.cache/rofi_wallpaper_picker
WALLPAPERS_DIR=$HOME/.config/wallpaper

rofi_cmd() {
	rofi -dmenu \
		-DPI 1.5 \
		-i \
                -p "Select wallpaper to change" \
		-theme $HOME/.config/rofi/wallpaper/style.rasi
}

if [ ! -d "${CACHE_DIR}" ] ; then
    mkdir -p "${CACHE_DIR}"
fi

for wallpaper in "$WALLPAPERS_DIR"/*.{jpg,jpeg,png}; do
    if [ -f "$wallpaper" ]; then
        wallpaper_name=$(basename "$wallpaper")
        if [ ! -f "${CACHE_DIR}/${wallpaper_name}" ] ; then
            magick "$wallpaper" -thumbnail '320x180>' "${CACHE_DIR}/${wallpaper_name}"
        fi
    fi
done

selected_wallpaper=$(find "${WALLPAPERS_DIR}" -type f -printf "%P\n" | sort | while read -r A ; do echo -en "$A\x00icon\x1f""${CACHE_DIR}"/"$A\n" ; done | rofi_cmd)

if [[ $selected_wallpaper == "" ]]; then
    exit 1
fi

selected_wallpaper_path=$WALLPAPERS_DIR/$selected_wallpaper

convert "$selected_wallpaper_path" /home/stefan/.config/bg.jpg
xwallpaper --zoom /home/stefan/.config/bg.jpg
wal -c
wal -i /home/stefan/.config/bg.jpg

#cd ~/.config/suckless/dwm-flexipatch
#sudo make clean install
#cd ~/.config/suckless/st-flexipatch
#sudo make clean install
#xdotool key alt+ctrl+shift+q
xrdb merge /home/stefan/.cache/wal/colors-dwm-xresources 
xdotool key alt+shift+F5
xrdb merge ~/.Xresources
pywalfox update
exit

# sh $HOME/.config/hypr/scripts/wallpaper_changer.sh $selected_wallpaper_path
# sh $HOME/.config/hypr/scripts/pywal_wrapper.sh -g $selected_wallpaper_path
