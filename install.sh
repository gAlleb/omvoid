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
source $OMVOID_INSTALL/preflight/update.sh
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
show_subtext "Installing terminal and main tools [2/5]"
source $OMVOID_INSTALL/development/docker.sh
source $OMVOID_INSTALL/development/hyprtime.sh
source $OMVOID_INSTALL/development/development.sh
source $OMVOID_INSTALL/development/sddm.sh
source $OMVOID_INSTALL/development/pipewire.sh
source $OMVOID_INSTALL/development/node.sh


# Desktop
show_logo 
show_subtext "Installing desktop tools [3/5]"
source $OMVOID_INSTALL/desktop/fonts.sh 
source $OMVOID_INSTALL/desktop/theme.sh

# # Apps
show_logo
show_subtext "Installing default applications [4/5]"
source $OMVOID_INSTALL/apps/spec.sh
source $OMVOID_INSTALL/apps/webapps.sh
source $OMVOID_INSTALL/apps/xtras.sh
source $OMVOID_INSTALL/apps/mimetypes.sh

show_logo
show_subtext "Installing void-packages repo and building apps [5/5]"
source $OMVOID_INSTALL/apps/voidpackages.sh 

# # Reboot
show_logo
show_subtext "We're done, you gorgeous! Rebooting now..."
sleep 3
sudo ln -s /etc/sv/sddm /var/service
sudo reboot
