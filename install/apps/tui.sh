#!/bin/bash

ICON_DIR="$HOME/.local/share/applications/icons"

omvoid-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/Disk Usage.png"
