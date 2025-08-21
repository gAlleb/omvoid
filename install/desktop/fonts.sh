#!/bin/bash
sudo cp -r ~/.local/share/omvoid/fonts/* /usr/share/fonts/ 
sudo fc-cache -fv
sudo xbps-install noto-fonts-ttf noto-fonts-ttf-extra liberation-fonts-ttf noto-fonts-emoji fonts-roboto-ttf dejavu-fonts-ttf noto-fonts-cjk nerd-fonts-symbols-ttf 
