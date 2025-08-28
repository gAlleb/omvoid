#!/bin/bash
# Hyprland
echo "repository=https://raw.githubusercontent.com/Makrennel/hyprland-void/repository-x86_64-glibc" | sudo tee /etc/xbps.d/hyprland-void.conf
sleep 3
sudo xbps-install -S
sudo xbps-install -y \
  hyprland hyprland-devel xdg-desktop-portal-hyprland \
  hyprland hyprwayland-scanner hyprutils hyprlang hyprlock \
  hypridle hyprsunset hyprland-qt-support libqalculate \
  polkit-gnome hyprland-qtutils hyprland-devel hyprgraphics\
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr mesa-dri
sudo sed -i 's/Exec=Hyprland/Exec=dbus-run-session Hyprland/' /usr/share/wayland-sessions/hyprland.desktop

