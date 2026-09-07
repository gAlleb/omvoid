#!/bin/bash

# Install packages
sudo xbps-install -y chrony dbus elogind polkit rtkit NetworkManager dbus-elogind cronie turnstile libspa-bluetooth bluez
# bluez-deprecated bluez-hid2hci are in bluez

# Enabled through omvoid-service-enable, not by linking into /var/service.
#
# /var/service is a symlink to ../run/runit/runsvdir/current, and /run is a
# tmpfs made at boot. On a running machine linking there works; in a system
# being installed it points at nothing, every link fails silently, and the
# machine comes up with no services at all. The helper writes to
# /etc/runit/runsvdir/default, which is right in both cases.
omvoid-service-enable chronyd dbus bluetoothd polkitd NetworkManager rtkit cronie

# elogind and turnstiled are deliberately left off.
# omvoid-service-enable elogind turnstiled

# dhcpcd is what a fresh Void enables. NetworkManager does the same job and the
# two fight over the same interfaces.
omvoid-service-enable --disable dhcpcd

# Add user to necessary groups
sudo usermod -aG network,dbus,polkitd $USER
