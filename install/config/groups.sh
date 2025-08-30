sudo usermod -aG audio,video,storage,input $USER 

sed -i 's|^source $OMVOID_INSTALL/config/groups.sh\s*$|#source $OMVOID_INSTALL/config/groups.sh|' ~/.local/share/omvoid/install.sh
