#!/bin/bash

git clone https://github.com/void-linux/void-packages.git ~/.local/pkgs/void-packages

(
  echo "Entering ~/.local/pkgs/void-packages"

  cd ~/.local/pkgs/void-packages || exit 1

  # 1. Prepare void repo
  ./xbps-src binary-bootstrap
  echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
  
  # 2. Copy templates to srcpkgs
  cp ~/.local/share/omvoid/srcpkgs/* ~/.local/pkgs/void-packages/srcpkgs/ 

  # 3. Install rofi-wayland
  ./xbps-src rofi-wayland
  xbps-install --repository hostdir/binpkgs rofi-wayland

  echo "Leaving subshell."
)
