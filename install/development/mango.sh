#!/bin/bash

sudo xbps-install -Sy \
  mangowc swaylock

sudo xbps-install -Sy \
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr 

sudo sed -i 's|Exec=mango|Exec=dbus-run-session mango|' /usr/share/wayland-sessions/mango.desktop
