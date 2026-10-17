#!/bin/bash

# Virtual machines: libvirt + QEMU/KVM, driven from virt-manager rather than
# virsh. https://docs.voidlinux.org/config/containers-and-vms/libvirt.html
#
# qemu-system-amd64, not "qemu": the full package pulls in every system
# emulator from alpha to xtensa and the user-mode ones besides, all of which
# then ride on the installation medium. qemu-img is what virt-manager creates
# disks with; edk2-ovmf boots UEFI guests, swtpm gives them a TPM (Windows 11
# refuses to install without one).
sudo xbps-install -y libvirt qemu-system-amd64 qemu-img edk2-ovmf swtpm \
  virt-manager virt-manager-tools

# The monolithic daemon, as the Void docs have it, not the split virtqemud /
# virtnetworkd set the package also ships. dbus and polkit are enabled by
# config/services.sh; without them membership in "libvirt" grants nothing.
omvoid-service-enable libvirtd virtlockd virtlogd

# "libvirt" opens qemu:///system to the user without root; "kvm" owns /dev/kvm.
# Both take effect at the next login.
sudo usermod -aG libvirt,kvm $USER

# The "default" NAT network needs no setup: the package ships it already
# marked for autostart (/etc/libvirt/qemu/networks/autostart/default.xml).
#
# Its ufw rules for virbr0 live in development/firewall.sh, not here: in a
# chroot no ufw command may run after that step -- see the end of it.
