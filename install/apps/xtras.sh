#!/bin/bash
# Copy over omvoid applications
source omvoid-refresh-applications || true

sed -i 's|^source $OMVOID_INSTALL/apps/xtras.sh\s*$|#source $OMVOID_INSTALL/apps/xtras.sh|' ~/.local/share/omvoid/install.sh
