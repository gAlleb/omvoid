#!/bin/bash
read -p "Would you like to clone void-packages repo and setup additional packages? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then

  if [ ! -d "~/.local/pkgs/void-packages" ]; then
  
  (
    git clone https://github.com/void-linux/void-packages.git ~/.local/pkgs/void-packages
  
    echo "Entering ~/.local/pkgs/void-packages"
  
    cd ~/.local/pkgs/void-packages || exit 1
  
    # 1. Prepare void repo
    ./xbps-src binary-bootstrap
    echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
    
    # 2. Copy templates to srcpkgs
    cp -r ~/.local/share/omvoid/srcpkgs/* ~/.local/pkgs/void-packages/srcpkgs/ 
  
    # 3. Install rofi-wayland
    ./xbps-src pkg rofi-wayland
    sudo xbps-install -y --repository hostdir/binpkgs rofi-wayland
  
    # 4. Install SwayOSD
    ./xbps-src pkg SwayOSD
    sudo xbps-install -y --repository hostdir/binpkgs SwayOSD 
    if [ ! -L "/var/service/swayosd-libinput-backend/" ]; then
      sudo ln -s /etc/sv/swayosd-libinput-backend /var/service
    fi
  
    echo "Leaving subshell."
  )
  
  fi

fi


