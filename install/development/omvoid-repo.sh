# Omvoid repo 
echo repository=https://raw.githubusercontent.com/galleb/voidlinux/repository-x86_64-glibc | sudo tee /etc/xbps.d/omvoid.conf

sudo xbps-install -S

sed -i 's|^source $OMVOID_INSTALL/development/omvoid-repo.sh\s*$|#source $OMVOID_INSTALL/development/omvoid-repo.sh|' ~/.local/share/omvoid/install.sh
