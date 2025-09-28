# Omvoid repo
# xbps-rindex --privkey ~/voidrepo.pem --sign --signedby "Stefan" ~/.local/github/voidlinux
# xbps-rindex --privkey ~/voidrepo.pem --sign-pkg  ~/.local/github/voidlinux/*.xbps

# Copy key

if [ ! -d /var/db/xbps/keys ] ; then
    sudo mkdir -p /var/db/xbps/keys
fi 

sudo cp -R ~/.local/share/omvoid/default/repokeyes/omvoid/* /var/db/xbps/keys/

echo repository=https://raw.githubusercontent.com/galleb/voidlinux/repository-x86_64-glibc | sudo tee /etc/xbps.d/omvoid.conf

sudo xbps-install -Sy discord gImageReader-gtk nwg-dock-hyprland kbdlightmac nwg-look nwg-drawer mpdris2-rs

sed -i 's|^source $OMVOID_INSTALL/development/omvoid-repo.sh\s*$|#source $OMVOID_INSTALL/development/omvoid-repo.sh|' ~/.local/share/omvoid/install.sh
