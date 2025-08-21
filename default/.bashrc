#
# ~/.bashrc
#
export MOZ_USE_XINPUT2=1
export BROWSER=brave-browser-stable
export TERMINAL=alacritty
export SVDIR=~/.config/service
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '
alias ls='ls --color=auto'
alias xi='sudo xbps-install'
alias xr='sudo xbps-remove'
alias n='nvim'
# PS1='[\u@\h \W]\$ '

#PS1="\e[00;36m\]┌─[ \e[00;37m\]\T \d \e[00;36m\]]──\e[00;31m\]>\e[00;37m\] \u\e[00;31m\]@\e[00;37m\]\h\n\e[00;36m\]|\n\e[00;36m\]└────\e[00;31m\]> \e[00;37m\]\w \e[00;31m\]\$ \e[01;37m\]"
#PS1="\[\033[1;33m\] \[\e[01;37m\]{ \[\e[01;34m\]\w \[\e[01;37m\]} \[\e[01;35m\]\[\$ \]\[\e[01;37m\]"
#PS1="\[\e[1;36m\]\$(parse_git_branch)\[\033[31m\]\$(parse_git_dirty)\[\033[00m\]\n\w\[\e[1;31m\] \[\e[1;36m\]\[\e[1;37m\] "
#PS1="\[\e[1;36m\]\$(parse_git_branch)\[\033[31m\]\$(parse_git_dirty)\n\[\033[1;33m\]  \[\e[1;37m\] \w \[\e[1;36m\]\[\e[1;37m\] "

PS1="\[\033[1;33m\] \[\e[01;37m\] \[\e[01;34m\]\w \[\e[1;33m\]󰅂 \[\e[0;37m\]"

#figlet home
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
# Not supported in the "fish" shell.
#(cat ~/.cache/wal/sequences &)
# Alternative (blocks terminal for 0-3ms)
#cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh
# Created by `pipx` on 2025-04-14 17:06:07
export PATH="$PATH:/home/stefan/.local/bin"

# to move to ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


