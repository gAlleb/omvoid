#!/bin/bash

# Main batch
sudo xbps-install -y \
  wget curl unzip fzf nano Waybar tmux \
  make base-devel freetype-devel fontconfig-devel \
  wl-clipboard wl-clip-persist cliphist fastfetch man tldr less ufw network-manager-applet \
  ImageMagick wf-recorder brightnessctl playerctl nautilus \
  libnotify imv lazydocker inotify-tools dust \
  nautilus gvfs mpd mpc cava SwayNotificationCenter \
  libcanberra-gtk3 libcanberra-utils sound-theme-freedesktop \
  wf-recorder satty slurp grim webp-pixbuf-loader swww \
  neovim alacritty kitty rofi walker gnome-keyring seahorse rmpc wlogout \
  caffeine-ng gnome-themes-extra xdg-user-dirs swaybg \
  SwayOSD kvantum qt5ct qt6ct xtools \
  tesseract-ocr tesseract-ocr-rus tesseract-ocr-eng tesseract-ocr-san

# X11 batch
sudo xbps-install -y \
  xwallpaper xcompmgr xsetroot libX11-devel picom \
  libXft-devel libXinerama-devel imlib2-devel xorg xinit 


# Extra batch 
sudo xbps-install -y \
  remmina flacon filezilla transmission transmission-qt gnome-calculator \
  foliate vscode obs audacity strawberry ghostty gimp chromium puddletag \
  senpai vlc mpv telegram-desktop papers

# pipx; python3-cairo-devel for waypaper to work
sudo xbps-install -y \
  python3-pipx python3-cairo-devel 

pipx install pywal16 waypaper

xdg-user-dirs-update 

sudo usermod -aG mpd,transmission $USER 

if [ ! -L "/var/service/swayosd-libinput-backend/" ]; then
    sudo ln -s /etc/sv/swayosd-libinput-backend /var/service
fi

# Add Gimp Photoshop plugin
git clone https://github.com/Diolinux/PhotoGIMP.git /tmp/PhotoGIMP

if [ -d ~/.config/GIMP ]; then
  mv ~/.config/GIMP ~/.config/GIMP_original
fi

cp -r /tmp/PhotoGIMP/.config/GIMP ~/.config/

sed -i 's|^source $OMVOID_INSTALL/development/development.sh\s*$|#source $OMVOID_INSTALL/development/development.sh|' ~/.local/share/omvoid/install.sh
