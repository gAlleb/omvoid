# .bash_profile
export EDITOR=nvim
export MOZ_USE_XINPUT2=1
export BROWSER=brave-origin-nightly
export TERMINAL=alacritty
export SVDIR=~/.config/service
export OMVOID_PATH=$HOME/.local/share/omvoid 
export PATH="$PATH:$HOME/.local/bin:$HOME/scripts:$HOME/.local/share/omvoid/bin:$OMVOID_PATH/bin:$HOME/.config/suckless/scripts"

# Шимы mise. eval "$(mise activate bash)" в .bashrc работает только в
# интерактивной оболочке -- в скриптах и runit-сервисах .bashrc не читается, и
# node там просто нет. Шимы закрывают именно эти случаи. В интерактивной
# оболочке они не мешают: activate дописывает свой каталог в начало PATH на
# каждой отрисовке приглашения и всё равно выигрывает.
export PATH="$PATH:$HOME/.local/share/mise/shims"
export LIBVIRT_DEFAULT_URI="qemu:///system"
# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/__USERNAME__/.opam/opam-init/init.sh' && . '/home/__USERNAME__/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true
# END opam configuration
# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc




