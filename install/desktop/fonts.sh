#!/bin/bash

font_urls=(
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Noto.tar.xz"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.tar.xz" 
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.tar.xz"
    "https://github.com/gAlleb/SFProDisplay/releases/download/v1.0.0/SFProDisplay.tar.xz"
)

font_dest_dir="$HOME/.local/share/fonts"

tmp_dir=$(mktemp -d)
trap 'echo "Cleaning up temporary directory..."; rm -rf "$tmp_dir"' EXIT

echo "Temporary download directory: $tmp_dir"
echo "---"

for url in "${font_urls[@]}"; do
    archive_name=$(basename "$url")
    font_name=$(basename "$archive_name" .tar.xz)
    echo "Processing '$font_name'..."
    echo "Downloading $archive_name..."
    wget -q -P "$tmp_dir" "$url"
    dest_path="$font_dest_dir/$font_name"
    mkdir -p "$dest_path"
    echo "Extracting to $dest_path..."
    tar -xf "$tmp_dir/$archive_name" -C "$dest_path"
    echo "---"
done


#font_src_dir="$HOME/.local/share/omvoid/fonts"

#for font_archive in "$font_src_dir"/*.tar.xz; do
#    font_name=$(basename "$font_archive" .tar.xz)
#    dest_dir="$font_dest_dir/$font_name"
#    mkdir -p "$dest_dir"
#    tar -xf "$font_archive" -C "$dest_dir"
#done

fc-cache -f -v

sudo xbps-install -y noto-fonts-ttf noto-fonts-ttf-extra liberation-fonts-ttf noto-fonts-emoji fonts-roboto-ttf dejavu-fonts-ttf noto-fonts-cjk nerd-fonts-symbols-ttf 

sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/60-latin.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/70-no-bitmaps-except-emoji.conf /etc/fonts/conf.d/ 

sed -i 's|^source $OMVOID_INSTALL/desktop/fonts.sh\s*$|#source $OMVOID_INSTALL/desktop/fonts.sh|' ~/.local/share/omvoid/install.sh
