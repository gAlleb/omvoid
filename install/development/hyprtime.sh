#!/bin/bash

# Hyprland

# Copy key 

if [ ! -d /var/db/xbps/keys ] ; then
    sudo mkdir -p /var/db/xbps/keys
fi 

sudo cp -R ~/.local/share/omvoid/default/repokeyes/hyprland/* /var/db/keys/

echo "repository=https://raw.githubusercontent.com/Makrennel/hyprland-void/repository-x86_64-glibc" | sudo tee /etc/xbps.d/hyprland-void.conf

sudo xbps-install -Sy \
  hyprland hyprland-devel xdg-desktop-portal-hyprland \
  hyprland hyprwayland-scanner hyprutils hyprlang hyprlock \
  hypridle hyprsunset hyprland-qt-support libqalculate \
  polkit-gnome hyprland-qtutils hyprland-devel hyprgraphics\
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr mesa-dri
sudo sed -i 's/Exec=Hyprland/Exec=dbus-run-session Hyprland/' /usr/share/wayland-sessions/hyprland.desktop

sed -i 's|^source $OMVOID_INSTALL/development/hyprtime.sh\s*$|#source $OMVOID_INSTALL/development/hyprtime.sh|' ~/.local/share/omvoid/install.sh
