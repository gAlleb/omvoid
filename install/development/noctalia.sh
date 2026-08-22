# noctalia repo

if [ ! -d /var/db/xbps/keys ] ; then
    sudo mkdir -p /var/db/xbps/keys
fi 

sudo cp -R ~/.local/share/omvoid/default/repokeyes/noctalia/* /var/db/xbps/keys/

echo "repository=https://repo.voiders.dev" | sudo tee /etc/xbps.d/10-voiders-community.conf

sudo xbps-install -Sy noctalia
