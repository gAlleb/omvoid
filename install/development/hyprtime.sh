#!/bin/bash

# Hyprland

# Copy key 
# Makrennel 30:93:47:9e:1f:55:c5:c5:07:b1:9a:e6:8b:10:5b:4b.plist 
# Encoded14 1d:c2:cf:d4:08:97:4c:47:5d:88:4c:fd:e9:a5:d0:9a.plist

if [ ! -d /var/db/xbps/keys ] ; then
    sudo mkdir -p /var/db/xbps/keys
fi 

sudo cp ~/.local/share/omvoid/default/repokeyes/hyprland/1d:c2:cf:d4:08:97:4c:47:5d:88:4c:fd:e9:a5:d0:9a.plist  /var/db/xbps/keys/

#echo "repository=https://raw.githubusercontent.com/Makrennel/hyprland-void/repository-x86_64-glibc" | sudo tee /etc/xbps.d/hyprland-void.conf
echo repository=https://raw.githubusercontent.com/Encoded14/void-extra/repository-x86_64 | sudo tee /etc/xbps.d/20-repository-extra.conf

sudo xbps-install -Sy \
  hyprland hyprland-devel xdg-desktop-portal-hyprland \
  hyprland hyprwayland-scanner hyprutils hyprlang hyprlock \
  hypridle hyprsunset hyprcursor hyprpicker \
  hyprland-devel hyprgraphics \
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr 

sudo sed -i 's/Exec=Hyprland/Exec=dbus-run-session Hyprland/' /usr/share/wayland-sessions/hyprland.desktop

sed -i 's|^source $OMVOID_INSTALL/development/hyprtime.sh\s*$|#source $OMVOID_INSTALL/development/hyprtime.sh|' ~/.local/share/omvoid/install.sh
