#!/bin/bash

# Set first-run mode marker so we can install stuff post-installation
mkdir -p ~/.local/state/omvoid
touch ~/.local/state/omvoid/first-run.mode

sed -i 's|^source $OMVOID_INSTALL/preflight/first-run-mode.sh\s*$|#source $OMVOID_INSTALL/preflight/first-run-mode.sh|' ~/.local/share/omvoid/install.sh
