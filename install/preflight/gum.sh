#!/bin/bash
sudo xbps-install -y gum

sed -i 's|^source $OMVOID_INSTALL/preflight/gum.sh\s*$|#source $OMVOID_INSTALL/preflight/gum.sh|' ~/.local/share/omvoid/install.sh
