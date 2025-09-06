#!/bin/bash
sudo xbps-install -y sddm qt6-svg qt6-virtualkeyboard qt6-multimedia layer-shell-qt 
sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/ 
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

if [ ! -d /etc/sddm.conf.d ] ; then
    sudo mkdir -p /etc/sddm.conf.d
fi 
 
sudo tee /etc/sddm.conf.d/virtualkbd.conf <<'EOF'
[General]
InputMethod=qtvirtualkeyboard
EOF

sudo tee /etc/sddm.conf.d/10-wayland.conf <<'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell,QT_SCREEN_SCALE_FACTORS=1
#QT_FONT_DPI=192
[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1 
EnableHiDPI=true
EOF

# set sddm wallpaper
sudo ln -s ~/.config/bg.jpg /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/background
sudo sed -i 's/Background="Backgrounds\/astronaut.png".*/Background="Backgrounds\/background"/' /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf

#sudo ln -s /etc/sv/sddm /var/service

sed -i 's|^source $OMVOID_INSTALL/development/sddm.sh\s*$|#source $OMVOID_INSTALL/development/sddm.sh|' ~/.local/share/omvoid/install.sh
