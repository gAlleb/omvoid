#!/bin/bash
sudo xbps-install -y rclone fuse3 autofs nfs-utils sv-netmount cifs-utils smbclient ntfs-3g 
sudo ln -sf /usr/bin/rclone /sbin/mount.rclone
sudo ln -sf /usr/bin/rclone /usr/bin/rclonefs

if [ -f /etc/fuse.conf ]; then
    # Anchored to the end of the line, and that anchor is the whole point.
    # Without it the pattern also matches the line of prose above the setting --
    # "#user_allow_other - Using the allow_other mount option works fine as
    # root, but" -- and uncommenting that leaves a sentence where fuse expects
    # an option. The check below then found the word at the start of that line
    # and reported success, so the damage stayed quiet.
    sudo sed -i 's/^#\s*user_allow_other\s*$/user_allow_other/' /etc/fuse.conf

    # Anchored for the same reason: the option occupies a line by itself.
    if ! grep -q '^user_allow_other\s*$' /etc/fuse.conf; then
        echo "user_allow_other" | sudo tee -a /etc/fuse.conf
    fi
else
    # If the file does not exist, create it with the required line.
    echo "user_allow_other" | sudo tee /etc/fuse.conf
fi

echo -e "/media /etc/autofs/auto.mymounts --timeout 0 --ghost\n" | sudo tee -a /etc/autofs/auto.master

sudo tee /etc/autofs/auto.mymounts <<'EOF'
#  
# fstype=fuse.rclonefs works, fstype=rclone - doesn't. TODO:
# symlink rclone binary to /sbin/mount.rclone and optionally /usr/bin/rclonefs
#
# EXAMPLE MOUNTPOINTS:
#
# NTFS DRIVES
#
#win11-data -fstype=ntfs-3g,uid=1000,gid=1000,windows_names :/dev/nvme0n1p4
#
# CIFS:
#music -fstype=cifs,rw,credentials=/etc/autofs/credentials,noperm ://192.168.1.14/music
#nextcloud -fstype=cifs,rw,credentials=/etc/autofs/credentials,noperm ://192.168.1.14/nextcloud
#
# NFS:
#truenas2 -rw,soft 192.168.1.14:/mnt/my-1tb-pool/music
#nextcloud -rw,soft 192.168.1.14:/mnt/my-1tb-pool/nextcloud
#
# CLOUD DRIVES:
#
#GoogleDrive -allow_other,args2env,fstype=fuse.rclonefs,config=/root/.config/rclone/rclone.conf,cache-db-purge,allow-other,vfs-cache-mode=writes :GoogleDrive:
#YandexDisk -allow_other,args2env,fstype=fuse.rclonefs,config=/root/.config/rclone/rclone.conf,cache-db-purge,allow-other,vfs-cache-mode=writes :YandexDiskLinux:

EOF

sudo mkdir -p /root/.config/rclone

sudo cp -r ~/.local/share/omvoid/config/rclone/rclone.conf /root/.config/rclone/

# /var/service does not exist in a system being installed -- it is a symlink
# into a tmpfs made at boot. See the note in install/config/services.sh.
omvoid-service-enable autofs netmount rpcbind statd
