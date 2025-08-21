sudo xbps-install -y chrony dbus elogind polkit rtkit NetworkManager dbus-elogind
sudo ln -s /etc/sv/chronyd /var/service
sudo ln -s /etc/sv/dbus /var/service
#sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/polkitd /var/service
sudo ln -s /etc/sv/NetworkManager /var/service
sudo ln -s /etc/sv/rtkit /var/service
sudo rm -r /var/service/dhcpcd

sudo usermod -aG network,dbus,polkitd $USER 
