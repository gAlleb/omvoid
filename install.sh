#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

export PATH="$HOME/.local/share/omvoid/bin:$PATH"
OMVOID_INSTALL=~/.local/share/omvoid/install

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mOMVOID installation failed!\e[0m"
  echo "You can retry by running: bash ~/.local/share/omvoid/install.sh"
}

trap catch_errors ERR

show_logo() {
  clear
  # tte -i ~/.local/share/omvoid/logo.txt --frame-rate ${2:-120} ${1:-expand}
  cat <~/.local/share/omvoid/logo.txt
  echo
}

show_subtext() {
  echo "$1" # | tte --frame-rate ${3:-640} ${2:-wipe}
  echo
}

# Install prerequisites
# source $OMVOID_INSTALL/preflight/migrations.sh
source $OMVOID_INSTALL/preflight/gum.sh

# Configuration
show_logo
show_subtext "Let's install OMVOID! [1/5]"
source $OMVOID_INSTALL/config/identification.sh
source $OMVOID_INSTALL/config/config.sh
source $OMVOID_INSTALL/config/services.sh
source $OMVOID_INSTALL/config/runsvdir.sh
source $OMVOID_INSTALL/config/groups.sh
source $OMVOID_INSTALL/config/rclone.sh
source $OMVOID_INSTALL/config/power.sh


# Development
show_logo
show_subtext "Installing terminal tools [2/5]"
source $OMVOID_INSTALL/development/docker.sh
source $OMVOID_INSTALL/development/hyprtime.sh
source $OMVOID_INSTALL/development/development.sh
source $OMVOID_INSTALL/development/sddm.sh
source $OMVOID_INSTALL/development/pipewire.sh
source $OMVOID_INSTALL/development/node.sh


# Desktop
show_logo 
source $OMVOID_INSTALL/desktop/fonts.sh
source ~/.config/hypr/scripts/init_wallpaper.sh
sudo ln -s /etc/sv/sddm /var/service

# # Desktop
# show_logo slice 60
# show_subtext "Installing desktop tools [3/5]"
# source $OMVOID_INSTALL/desktop/theme.sh
# source $OMVOID_INSTALL/desktop/bluetooth.sh
# source $OMVOID_INSTALL/desktop/asdcontrol.sh
# source $OMVOID_INSTALL/desktop/fonts.sh
# source $OMVOID_INSTALL/desktop/printer.sh

# # Apps
# show_logo
# show_subtext "Installing default applications [4/5]"
# source $OMVOID_INSTALL/apps/webapps.sh
# source $OMVOID_INSTALL/apps/xtras.sh
# source $OMVOID_INSTALL/apps/mimetypes.sh

# # Updates
# show_logo
# show_subtext "Updating system packages [5/5]"
# sudo updatedb
# yay -Syu --noconfirm --ignore uwsm

# # Reboot
show_logo
show_subtext "You're done, you gorgeous! Rebooting now..."
sleep 3
sudo reboot
