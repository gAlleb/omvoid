#!/bin/bash

ansi_art='                                                   
       ██████╗ ███╗   ███╗██╗   ██╗ ██████╗ ██╗██████╗       
      ██╔═══██╗████╗ ████║██║   ██║██╔═══██╗██║██╔══██╗      
█████╗██║   ██║██╔████╔██║██║   ██║██║   ██║██║██║  ██║█████╗
╚════╝██║   ██║██║╚██╔╝██║ ██╗ ██╔╝██║   ██║██║██║  ██║╚════╝
      ╚██████╔╝██║ ╚═╝ ██║ ╚████╔╝ ╚██████╔╝██║██████╔╝      
       ╚═════╝ ╚═╝     ╚═╝  ╚═══╝   ╚═════╝ ╚═╝╚═════╝ 
        1101100 110011 110011 1110100 100000 1100101 
       1100100 1101001 1110100 1101001 1101111 1101110'

clear
echo -e "\n$ansi_art\n"

sudo xbps-install -y git

# Use custom repo if specified, otherwise default to basecamp/omarchy
OMVOID_REPO="${OMVOID_REPO:-galleb/omvoid}"

echo -e "\nCloning OMVOID from: https://github.com/${OMVOID_REPO}.git"
rm -rf ~/.local/share/omvoid/
git clone "https://github.com/${OMVOID_REPO}.git" ~/.local/share/omvoid >/dev/null

echo -e "\nInstallation starting..."
source ~/.local/share/omvoid/install.sh
