#!/bin/bash
sudo xbps-install -y sassc glib-devel nwg-look

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 /tmp/WhiteSur-gtk-theme
/tmp/WhiteSur-gtk-theme/install.sh
/tmp/WhiteSur-gtk-theme/install.sh -l
/tmp/WhiteSur-gtk-theme/install.sh -l -c light
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
/tmp/WhiteSur-icon-theme/install.sh
/tmp/WhiteSur-icon-theme/install.sh -t grey
/tmp/WhiteSur-icon-theme/install.sh -t purple
/tmp/WhiteSur-icon-theme/install.sh -t red
/tmp/WhiteSur-icon-theme/install.sh -t orange

gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-red-dark"

# Init random wallpapeper theme 
source ~/.config/hypr/scripts/init_wallpaper.sh

# Setup theme links
mkdir -p ~/.config/omvoid/themes
for f in ~/.local/share/omvoid/themes/*; do ln -nfs "$f" ~/.config/omvoid/themes/; done

# Set initial theme
mkdir -p ~/.config/omvoid/current
ln -snf ~/.config/omvoid/themes/redpeace ~/.config/omvoid/current/theme
ln -snf ~/.config/omvoid/current/theme/backgrounds/redpeace.png ~/.config/omvoid/current/background


