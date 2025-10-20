#!/bin/bash

# Main batch
sudo xbps-install -y \
  wget curl unzip fzf nano tmux xmlstarlet libqalculate \
  make base-devel freetype-devel fontconfig-devel nwg-look \
  fastfetch man tldr less ufw ImageMagick brightnessctl \
  playerctl nautilus libnotify imv lazydocker inotify-tools \
  dust blueman nautilus gvfs mpd mpc cava polkit-gnome \
  libcanberra-gtk3 libcanberra-utils sound-theme-freedesktop \
  webp-pixbuf-loader neovim alacritty kitty rofi gnome-keyring \
  seahorse rmpc caffeine-ng gnome-themes-extra xdg-user-dirs \
  kvantum qt5ct qt6ct xtools libinput-gestures mesa-dri \
  tesseract-ocr tesseract-ocr-rus tesseract-ocr-eng tesseract-ocr-san \
  gearlever mpdris2-rs fuzzypkg

# X11 batch
sudo xbps-install -y \
  xwallpaper xsetroot libX11-devel picom xautolock \
  libXft-devel libXinerama-devel imlib2-devel xorg xinit xsel \
  xdotool xclip slop maim clipmenu slock

# Solo Wayland batch 
sudo xbps-install -y \
  Waybar wl-clipboard wl-clip-persist cliphist wf-recorder \
  SwayNotificationCenter satty slurp grim swww walker \
  wlogout swaybg SwayOSD 

# Extra batch 
sudo xbps-install -y \
  remmina flacon filezilla transmission transmission-qt gnome-calculator \
  foliate vscode obs audacity strawberry ghostty gimp chromium puddletag \
  senpai vlc mpv telegram-desktop papers faba-icon-theme

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
