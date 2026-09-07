# Themes.
#
# WhiteSur used to be three git clones and six runs of upstream installers on
# every machine -- about ten minutes, and the gtk one needed a patch applied to
# its sources first to keep it from touching GNOME Shell. All of that now
# happens once, when the package is built.

sudo xbps-install -y nwg-look
sudo xbps-install -y WhiteSur-gtk-theme WhiteSur-icon-theme WhiteSur-kde

# The libadwaita part is a user file, so a package cannot place it: GTK4
# applications read it from ~/.config/gtk-4.0, and it is the copy whose
# @define-color lines omvoid's palette overrides. The package carries it aside,
# and it is copied into place here.
if [[ -d /usr/share/WhiteSur-gtk-theme/gtk-4.0 ]]; then
  mkdir -p ~/.config/gtk-4.0
  cp -a /usr/share/WhiteSur-gtk-theme/gtk-4.0/. ~/.config/gtk-4.0/
fi

# gsettings reaches dconf over the session bus. Installing from the medium there
# is no bus and no /etc/machine-id to autolaunch one, so these three writes fail
# and set -e ends the install right here -- on the theme itself. A throwaway bus
# is enough: dconf still writes ~/.config/dconf/user, which the real session
# reads at first login. With a bus already present, nothing changes.
omvoid_set_gtk_theme() {
  gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-red-dark"
}

if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  omvoid_set_gtk_theme
else
  export -f omvoid_set_gtk_theme
  dbus-run-session -- bash -c omvoid_set_gtk_theme
fi
# kvantummanager --set WhiteSur-opaqueDark

# Setup theme links
mkdir -p ~/.config/omvoid/themes
for f in ~/.local/share/omvoid/themes/*; do ln -nfs "$f" ~/.config/omvoid/themes/; done

# Set initial theme
mkdir -p ~/.config/omvoid/current
ln -snf ~/.config/omvoid/themes/redpeace ~/.config/omvoid/current/theme
# Pointed at the file, not through the theme link. Written as
# current/theme/backgrounds/... it silently means a different file the moment
# the theme changes -- which is how a machine ended up with a background link
# naming a picture that does not exist in the theme it now uses.
ln -snf ~/.config/omvoid/themes/redpeace/backgrounds/redpeace.png ~/.config/omvoid/current/background

# Add managed policy directories for Chromium and Brave for theme changes
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed

sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed

# Telegram theme generator, a package now rather than a clone and make install.
sudo xbps-install -y wal-telegram

# Init random wallpapeper theme with wal
source ~/.local/share/omvoid/bin/omvoid-init-wallpaper
