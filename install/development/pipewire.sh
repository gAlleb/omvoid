#!/bin/bash
sudo xbps-install -y pipewire wireplumber

mkdir -p ~/.config/pipewire/pipewire.conf.d

ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf ~/.config/pipewire/pipewire.conf.d/

ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf ~/.config/pipewire/pipewire.conf.d/

sudo xbps-install -y pulseaudio-utils pavucontrol

# alsa-pipewire

sudo xbps-install -y alsa-pipewire

sudo mkdir -p /etc/alsa/conf.d

sudo ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d

sudo ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d
