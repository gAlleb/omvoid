#!/bin/bash

# Copy over omvoid configs

if [ ! -d ~/.config ] ; then
    mkdir -p ~/.config
fi
if [ ! -d ~/.local/bin ] ; then
    mkdir -p ~/.local/bin
fi 

cp -R ~/.local/share/omvoid/config/* ~/.config/

# Use default dotfiles from omvoid
cp ~/.local/share/omvoid/default/.bashrc ~/.bashrc
cp ~/.local/share/omvoid/default/.bash_profile ~/.bash_profile
cp ~/.local/share/omvoid/default/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master

# Set identification from install inputs
if [[ -n "${OMVOID_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$OMVOID_USER_NAME"
fi

if [[ -n "${OMVOID_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$OMVOID_USER_EMAIL"
fi

if [[ -n "${OMVOID_USER_CITY//[[:space:]]/}" ]]; then
  sed -i "s/^LOCATION=.*/LOCATION=$OMVOID_USER_CITY/" ~/.config/hypr/scripts/forecast-hypr.sh
fi

sed -i 's|^source $OMVOID_INSTALL/config/config.sh\s*$|#source $OMVOID_INSTALL/config/config.sh|' ~/.local/share/omvoid/install.sh
