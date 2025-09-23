#!/bin/bash
sudo xbps-install -y sassc glib-devel nwg-look

# Install gtk theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 /tmp/WhiteSur-gtk-theme
/tmp/WhiteSur-gtk-theme/install.sh
/tmp/WhiteSur-gtk-theme/install.sh -l
/tmp/WhiteSur-gtk-theme/install.sh -l -c light

# install icon theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon-theme
/tmp/WhiteSur-icon-theme/install.sh
/tmp/WhiteSur-icon-theme/install.sh -t grey
/tmp/WhiteSur-icon-theme/install.sh -t purple
/tmp/WhiteSur-icon-theme/install.sh -t red
/tmp/WhiteSur-icon-theme/install.sh -t orange

# Install qt theme for Kvantum
git clone https://github.com/vinceliuice/WhiteSur-kde /tmp/WhiteSur-kde
/tmp/WhiteSur-kde/install.sh
/tmp/WhiteSur-kde/install.sh --window opaque 

gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-red-dark"
# kvantummanager --set WhiteSur-opaqueDark

# Init random wallpapeper theme with wal 
source ~/.config/hypr/scripts/init_wallpaper.sh

# Setup theme links
mkdir -p ~/.config/omvoid/themes
for f in ~/.local/share/omvoid/themes/*; do ln -nfs "$f" ~/.config/omvoid/themes/; done

# Set initial theme
mkdir -p ~/.config/omvoid/current
ln -snf ~/.config/omvoid/themes/redpeace ~/.config/omvoid/current/theme
ln -snf ~/.config/omvoid/current/theme/backgrounds/redpeace.png ~/.config/omvoid/current/background

# Add managed policy directories for Chromium and Brave for theme changes
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed

sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed

sed -i 's|^source $OMVOID_INSTALL/desktop/theme.sh\s*$|#source $OMVOID_INSTALL/desktop/theme.sh|' ~/.local/share/omvoid/install.sh
