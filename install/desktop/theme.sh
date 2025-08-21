#!/bin/bash
sudo xbps-install -y sassc glib-devel nwg-look

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 /tmp/WhiteSur-gtk-theme
/tmp/WhiteSur-gtk-theme/install.sh -c dark
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
/tmp/WhiteSur-icon-theme/install.sh

gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"

source ~/.config/hypr/scripts/init_wallpaper.sh
