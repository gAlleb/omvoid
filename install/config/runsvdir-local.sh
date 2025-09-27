#!/bin/sh
mkdir -p ~/.config/service/

cp -r ~/.local/share/omvoid/config/sv_runsvdir_local/* ~/.config/service/

sed -i 's|^exec-once = mpdris2-rs\s*$|#exec-once = mpdris2-rs|' ~/.config/hypr/config/autostart.conf

sed -i 's|^#exec-once = runsvdir -P ~/.config/service\s*$|exec-once = runsvdir -P ~/.config/service|' ~/.config/hypr/config/autostart.conf

sed -i 's|^source $OMVOID_INSTALL/config/runsvdir-local.sh\s*$|#source $OMVOID_INSTALL/config/runsvdir-local.sh|' ~/.local/share/omvoid/install.sh
