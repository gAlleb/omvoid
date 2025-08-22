# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc
#startx

# Created by `pipx` on 2025-04-14 17:06:07
export PATH="$PATH:$HOME/.local/bin:$HOME/scripts"

export LIBVIRT_DEFAULT_URI="qemu:///system"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/__USERNAME/.opam/opam-init/init.sh' && . '/home/__USERNAME__/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true
# END opam configuration
