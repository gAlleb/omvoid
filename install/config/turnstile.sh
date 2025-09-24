#!/bin/sh

mkdir -p ~/.config/service/dbus

sudo ln -s /usr/share/examples/turnstile/dbus.run ~/.config/service/dbus/run
sudo ln -s /usr/share/examples/turnstile/dbus.check ~/.config/service/dbus/check

ln -s ~/.config/sv/pipewire ~/.config/service

sed -i 's|^source $OMVOID_INSTALL/config/turnstile.sh\s*$|#source $OMVOID_INSTALL/config/runsvdir.sh|' ~/.local/share/omvoid/install.sh
