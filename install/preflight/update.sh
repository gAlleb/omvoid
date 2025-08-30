#!/bin/bash
sudo xbps-install -Su -y

sed -i 's|^source $OMVOID_INSTALL/preflight/update.sh\s*$|#source $OMVOID_INSTALL/preflight/update.sh|' ~/.local/share/omvoid/install.sh
