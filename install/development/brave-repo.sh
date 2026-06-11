# Jake's repo 

if [ ! -d /var/db/xbps/keys ] ; then
    sudo mkdir -p /var/db/xbps/keys
fi 

sudo cp -R ~/.local/share/omvoid/default/repokeyes/jake/* /var/db/xbps/keys/

echo repository=https://codeberg.org/JakeAtLinux/void-repo/raw/branch/main/x86_64 | sudo tee /etc/xbps.d/jake-void-repo.conf

sudo xbps-install -Sy brave-origin-bin
