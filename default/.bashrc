#
# ~/.bashrc
#
export MOZ_USE_XINPUT2=1
export BROWSER=brave-browser
export TERMINAL=alacritty
export SVDIR=~/.config/service
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias xi='sudo xbps-install'
alias xr='sudo xbps-remove'
alias n='nvim'

PS1="\[\033[1;33m\] \[\e[01;37m\] \[\e[01;34m\]\w \[\e[1;33m\]󰅂 \[\e[0;37m\]"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


