#!/bin/bash
sudo xbps-install -y pipewire wireplumber

mkdir -p ~/.config/pipewire/pipewire.conf.d

ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf ~/.config/pipewire/pipewire.conf.d/

ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf ~/.config/pipewire/pipewire.conf.d/

sudo xbps-install -y pulseaudio-utils pavucontrol

sed -i 's|^source $OMVOID_INSTALL/development/pipewire.sh\s*$|#source $OMVOID_INSTALL/development/pipewire.sh|' ~/.local/share/omvoid/install.sh
