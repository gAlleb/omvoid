#!/bin/bash

source "$OMVOID_INSTALL/lib/sources.sh"

# Copy over omvoid configs

if [ ! -d ~/.config ] ; then
    mkdir -p ~/.config
fi

if [ ! -d ~/.local/bin ] ; then
    mkdir -p ~/.local/bin
fi 

if [ ! -d ~/.gnupg ] ; then
    mkdir -p ~/.gnupg
fi 

cp -R ~/.local/share/omvoid/config/* ~/.config/

# Copy default gpg-agent.conf
cp ~/.local/share/omvoid/default/gnupg/gpg-agent.conf ~/.gnupg/

# Use default dotfiles from omvoid
cp ~/.local/share/omvoid/default/.bashrc ~/.bashrc
cp ~/.local/share/omvoid/default/.gtkrc-2.0 ~/.gtkrc-2.0

# Copy .bash_profile and change user
cp ~/.local/share/omvoid/default/.bash_profile ~/.bash_profile
sed -i "s/__USERNAME__/$USER/g" ~/.bash_profile

sudo xbps-install -y tmux

# tmux plugins.
#
# Taken from the installation medium when there is one -- they are git checkouts
# and cloning them needs a network the machine may not have. Otherwise cloned as
# before.
if [ -d /usr/local/share/omvoid/tmux-plugins ] && [ ! -d ~/.config/tmux/plugins/tpm ]; then
  mkdir -p ~/.config/tmux/plugins
  cp -a /usr/local/share/omvoid/tmux-plugins/. ~/.config/tmux/plugins/
elif [ ! -d ~/.config/tmux/plugins/tpm ]; then
  # git is not guaranteed yet: development.sh installs it, and that runs later.
  # It happens to be present when the repository arrived by cloning -- which is
  # why this never came up -- and absent when it arrived any other way, such as
  # copied onto a fresh machine.
  command -v git >/dev/null || sudo xbps-install -y git
  git clone "${GIT_SOURCES[tpm]}" ~/.config/tmux/plugins/tpm
fi

# Installs anything the copy above did not bring. Allowed to fail: with no
# network it can do nothing, and the plugins are already in place.
~/.config/tmux/plugins/tpm/bin/install_plugins || true

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
  sed -i "s/^LOCATION=.*/LOCATION=$OMVOID_USER_CITY/" ~/.config/waybar/scripts/forecast.sh
  sed -i "s/^LOCATION=.*/LOCATION=$OMVOID_USER_CITY/" ~/.config/tmux/tmux.conf
fi
