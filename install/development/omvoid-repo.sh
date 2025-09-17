# Omvoid repo
# xbps-rindex --privkey ~/voidrepo.pem --sign --signedby "Stefan" ~/.local/github/voidlinux
# xbps-rindex --privkey ~/voidrepo.pem --sign-pkg  ~/.local/github/voidlinux/*.xbps

echo repository=https://raw.githubusercontent.com/galleb/voidlinux/repository-x86_64-glibc | sudo tee /etc/xbps.d/omvoid.conf

sudo xbps-install -S

sudo xbps-install discord gImageReader-gtk nwg-dock-hyprland kbdlightmac nwg-look nwg-drawer

sed -i 's|^source $OMVOID_INSTALL/development/omvoid-repo.sh\s*$|#source $OMVOID_INSTALL/development/omvoid-repo.sh|' ~/.local/share/omvoid/install.sh
