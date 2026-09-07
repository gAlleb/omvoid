#!/bin/bash

source "$OMVOID_INSTALL/lib/sources.sh"

# Main batch
sudo xbps-install -y \
  wget curl unzip fzf nano tmux xmlstarlet libqalculate \
  make base-devel freetype-devel fontconfig-devel nwg-look \
  fastfetch man tldr less ufw ImageMagick brightnessctl zip \
  playerctl nautilus libnotify imv lazydocker inotify-tools \
  dust blueman nautilus gvfs mpd mpc cava polkit-gnome bsdtar \
  libcanberra-gtk3 libcanberra-utils sound-theme-freedesktop \
  webp-pixbuf-loader neovim alacritty kitty rofi gnome-keyring \
  seahorse rmpc caffeine-ng gnome-themes-extra xdg-user-dirs libXrandr-devel \
  kvantum qt5ct qt6ct xtools libinput-gestures mesa-dri yq lm_sensors \
  tesseract-ocr tesseract-ocr-rus tesseract-ocr-eng tesseract-ocr-san \
  gearlever mpdris2-rs fuzzypkg yazi python3-watchdog libxkbcommon-tools \
  bind-utils ripdrag keepassxc gajim exfat-utils fuse-exfat bat fd \
  neomutt msmtp pass gettext isync goimapnotify pam-gnupg lynx notmuch \
  urlview abook w3m mesa-vulkan-intel vulkan-loader mesa-vulkan-lavapipe \
  ripgrep pinentry-qt wireless-regdb

# X11 batch
sudo xbps-install -y \
  xwallpaper xsetroot libX11-devel picom xautolock \
  libXft-devel libXinerama-devel imlib2-devel xorg xinit xsel \
  xdotool xclip slop maim clipmenu slock

# Solo Wayland batch 
sudo xbps-install -y \
  Waybar wl-clipboard wl-clip-persist cliphist wf-recorder \
  dunst satty slurp grim awww \
  wlogout swaybg SwayOSD crystal-dock wlr-randr wlopm swaylock \
  swayidle qt5-wayland xorg-server-xwayland

# Extra batch 
sudo xbps-install -y \
  remmina flacon filezilla transmission transmission-qt gnome-calculator \
  foliate obs audacity strawberry ghostty gimp puddletag \
  senpai vlc mpv telegram-desktop papers faba-icon-theme

# pipx; python3-cairo-devel for waypaper to work
sudo xbps-install -y \
  python3-pipx python3-cairo-devel 

# pywal16, the sixteen-colour fork, as a package rather than through pipx.
# pipx put it in ~/.local/bin, which is not on PATH during an install -- so the
# installer could not find "wal" at the one moment it needed it.
sudo xbps-install -y python3-pywal16

# Brave and noctalia. Each used to be a step of its own -- development/brave-repo.sh
# and development/noctalia.sh -- holding one install line and a note saying the
# repository was configured elsewhere. Two extra xbps transactions for two
# packages, in a step that already installs from those repositories.
#
# No -S: on an install from the image these are already in place from the
# medium's mirror, and syncing would reach for a network that may not be there.
# Their repositories and keys come from development/omvoid-repo.sh, which runs
# first in this block.
sudo xbps-install -y brave-origin-bin noctalia

xdg-user-dirs-update 

sudo usermod -aG mpd,transmission $USER 

# /var/service does not exist in a system being installed -- it is a symlink
# into a tmpfs made at boot. See the note in install/config/services.sh.
omvoid-service-enable swayosd-libinput-backend
# Add Gimp Photoshop plugin
# PhotoGIMP is not installed any more -- left here rather than deleted so the
# way it was set up is not lost.
# git clone "${GIT_SOURCES[PhotoGIMP]}" /tmp/PhotoGIMP
#
# if [ -d ~/.config/GIMP ]; then
#   mv ~/.config/GIMP ~/.config/GIMP_original
# fi
#
# cp -r /tmp/PhotoGIMP/.config/GIMP ~/.config/
