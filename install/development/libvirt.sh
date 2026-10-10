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
# ufw does need telling, or the guests get no address: their DHCP and DNS go to
# the host's dnsmasq on virbr0 -- incoming, so dropped -- and their traffic out
# is forwarded, which "deny routed" drops whatever libvirt's own nftables table
# accepts. Runs after development/firewall.sh, which installs ufw.
sudo ufw allow in on virbr0 comment 'libvirt guests: dhcp, dns'
sudo ufw route allow in on virbr0 comment 'libvirt guests: nat out'
