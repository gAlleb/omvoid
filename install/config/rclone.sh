#!/bin/bash
sudo xbps-install -y rclone fuse3 autofs nfs-utils sv-netmount cifs-utils smbclient 
sudo ln -sf /usr/bin/rclone /sbin/mount.rclone
sudo ln -sf /usr/bin/rclone /usr/bin/rclonefs

if [ -f /etc/fuse.conf ]; then
    # If it exists, first try to uncomment the line.
    # The \s* handles optional whitespace like '# user_allow_other'
    sudo sed -i 's/^#\s*user_allow_other/user_allow_other/' /etc/fuse.conf
    
    # Now, verify the line is present. If not, add it.
    # This covers the case where the file existed but the line was missing.
    if ! grep -q '^user_allow_other' /etc/fuse.conf; then
        echo "user_allow_other" | sudo tee -a /etc/fuse.conf
    fi
else
    # If the file does not exist, create it with the required line.
    echo "user_allow_other" | sudo tee /etc/fuse.conf
fi

echo -e "/media /etc/autofs/auto.mymounts --timeout 0 --ghost\n" | sudo tee -a /etc/autofs/auto.master

sudo tee /etc/autofs/auto.mymounts <<'EOF'
# fstype=fuse.rclonefs works, fstype=rclone - doesn't. TODO:
# symlink rclone binary to /sbin/mount.rclone and optionally /usr/bin/rclonefs
#music -fstype=cifs,rw,credentials=/etc/autofs/credentials,noperm ://192.168.1.14/music
#nextcloud -fstype=cifs,rw,credentials=/etc/autofs/credentials,noperm ://192.168.1.14/nextcloud
truenas2 -rw,soft 192.168.1.14:/mnt/my-1tb-pool/music
nextcloud -rw,soft 192.168.1.14:/mnt/my-1tb-pool/nextcloud
GoogleDrive -allow_other,args2env,fstype=fuse.rclonefs,config=/root/.config/rclone/rclone.conf,cache-db-purge,allow-other,vfs-cache-mode=writes :GoogleDrive:
YandexDisk -allow_other,args2env,fstype=fuse.rclonefs,config=/root/.config/rclone/rclone.conf,cache-db-purge,allow-other,vfs-cache-mode=writes :YandexDiskLinux:

EOF

sudo mkdir -p /root/.config/rclone
sudo cp -r ~/.local/share/omvoid/config/rclone/rclone.conf /root/.config/rclone/
sudo ln -s /etc/sv/autofs /var/service/ 
sudo ln -s /etc/sv/netmount /var/service/ 
sudo ln -s /etc/sv/rpcbind /var/service/ 
sudo ln -s /etc/sv/statd /var/service/ 
