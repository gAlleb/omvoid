#!/bin/sh

mkdir -p ~/.config/service/dbus

sudo ln -s /usr/share/examples/turnstile/dbus.run ~/.config/service/dbus/run
sudo ln -s /usr/share/examples/turnstile/dbus.check ~/.config/service/dbus/check

cp -r ~/.local/share/omvoid/config/sv_turnstile/* ~/.config/service/

sed -i 's|^source $OMVOID_INSTALL/config/turnstile.sh\s*$|#source $OMVOID_INSTALL/config/turnstile.sh|' ~/.local/share/omvoid/install.sh
