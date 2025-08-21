#!/bin/bash
sudo mkdir /usr/share/fonts/JetBrainsMono
sudo tar -xf ~/.local/share/omvoid/fonts/JetBrainsMono.tar.xz -C /usr/share/fonts/JetBrainsMono
sudo tar -xf ~/.local/share/omvoid/fonts/sf-pro-display.tar.xz -C /usr/share/fonts/
sudo fc-cache -fv
sudo xbps-install -y noto-fonts-ttf noto-fonts-ttf-extra liberation-fonts-ttf noto-fonts-emoji fonts-roboto-ttf dejavu-fonts-ttf noto-fonts-cjk nerd-fonts-symbols-ttf 
