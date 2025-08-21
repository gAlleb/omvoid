#!/bin/bash
sudo xbps-install -y \
  wget curl unzip fzf nano Waybar senpai \
  make base-devel freetype-devel fontconfig-devel \
  xwallpaper xcompmgr xsetroot figlet lxappearance libX11-devel \
  libXft-devel libXinerama-devel  imlib2-devel xorg xinit \
  wl-clipboard fastfetch man tldr less ufw network-manager-applet \
  ImageMagick wf-recorder brightnessctl playerctl nautilus \
  libnotify pywal python3-pipx \
  nautilus gvfs mpd mpc mpDris2 cava SwayNotificationCenter \
  libcanberra-gtk3 libcanberra-utils sound-theme-freedesktop \
  wf-recorder satty slurp grim webp-pixbuf-loader mpv swww \
  neovim alacritty kitty walker gnome-keyring seahorse rmpc wlogout \
  caffeine-ng telegram-desktop gnome-themes-extra xdg-user-dirs swaybg \
  remmina flacon filezilla transmission transmission-qt gnome-calculator \
  foliate vscode obs audacity strawberry ghostty gimp

xdg-user-dirs-update
sudo usermod -aG mpd,transmission $USER 


