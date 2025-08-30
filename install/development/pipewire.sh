#!/bin/bash
sudo xbps-install -y pipewire wireplumber

sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/

sudo mkdir -p /etc/pipewire/pipewire.conf.d
sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

sudo xbps-install -y pulseaudio-utils pavucontrol

sed -i 's|^source $OMVOID_INSTALL/development/pipewire.sh\s*$|#source $OMVOID_INSTALL/development/pipewire.sh|' ~/.local/share/omvoid/install.sh
