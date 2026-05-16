#!/bin/bash

sudo xbps-install -Sy \
  mango swaylock

sudo xbps-install -Sy \
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr 

sudo sed -i 's|Exec=mango|Exec=dbus-run-session mango|' /usr/share/wayland-sessions/mango.desktop

sed -i 's|^source $OMVOID_INSTALL/development/mango.sh\s*$|#source $OMVOID_INSTALL/development/mango.sh|' ~/.local/share/omvoid/install.sh
