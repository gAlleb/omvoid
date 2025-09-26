# Copy all bundled icons to the applications/icons directory
ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"
cp ~/.local/share/omvoid/applications/icons/*.png "$ICON_DIR/"
sed -i 's|^source $OMVOID_INSTALL/apps/icons.sh\s*$|#source $OMVOID_INSTALL/apps/icons.sh|' ~/.local/share/omvoid/install.sh
