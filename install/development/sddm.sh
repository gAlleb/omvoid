#!/bin/bash

sudo xbps-install -y sddm qt6-svg qt6-virtualkeyboard qt6-multimedia layer-shell-qt 
# The theme is a package now, not a clone into /usr/share.
sudo xbps-install -y sddm-astronaut-theme
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
echo "@reboot root cp /home/$USER/.config/bg.jpg /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/background" | sudo tee /etc/cron.d/sddm-background > /dev/null

sudo sed -i 's/Background="Backgrounds\/astronaut.png".*/Background="Backgrounds\/background"/' /usr/share/sddm/themes/sddm-astronaut-theme/Themes/astronaut.conf

# Not enabled here. install.sh switches it on at the very end, after everything
# else is done -- runit picks the service up within seconds, and sddm would
# otherwise take over the console with the install still running behind it.
