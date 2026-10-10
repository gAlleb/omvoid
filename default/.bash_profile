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

# Inside a virtual machine, let wlroots draw the cursor itself. With virtio-gpu
# and 3D the hardware cursor plane comes out upside down (seen in
# omvoid-iso-test with virtio-vga-gl). Set here because SDDM starts the session
# through a bash login shell, so mango inherits it; "env =" in mango's own
# config would reach only the programs it starts, not mango. The "hypervisor"
# CPU flag is there in any guest -- KVM, VirtualBox, VMware -- and never on
# bare metal, so real machines keep their hardware cursor.
if grep -q '^flags.* hypervisor' /proc/cpuinfo 2>/dev/null; then
  export WLR_NO_HARDWARE_CURSORS=1
fi
# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc




