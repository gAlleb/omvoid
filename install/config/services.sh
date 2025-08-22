#!/bin/bash

# Install packages
sudo xbps-install -y chrony dbus elogind polkit rtkit NetworkManager dbus-elogind

# Create symbolic links only if they don't exist
if [ ! -L "/var/service/chronyd" ]; then
    sudo ln -s /etc/sv/chronyd /var/service
fi

if [ ! -L "/var/service/dbus" ]; then
    sudo ln -s /etc/sv/dbus /var/service
fi

#if [ ! -L "/var/service/elogind" ]; then
#    sudo ln -s /etc/sv/elogind /var/service
#fi

if [ ! -L "/var/service/polkitd" ]; then
    sudo ln -s /etc/sv/polkitd /var/service
fi

if [ ! -L "/var/service/NetworkManager" ]; then
    sudo ln -s /etc/sv/NetworkManager /var/service
fi

if [ ! -L "/var/service/rtkit" ]; then
    sudo ln -s /etc/sv/rtkit /var/service
fi

# Remove dhcpcd service directory if it exists
if [ -d "/var/service/dhcpcd" ]; then
    sudo rm -r /var/service/dhcpcd
fi

# Add user to necessary groups
sudo usermod -aG network,dbus,polkitd $USER
