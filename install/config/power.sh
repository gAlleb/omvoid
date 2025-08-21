#!/bin/bash

# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.
sudo xbps-install -y tlp power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  # sudo ln -s /etc/sv/power-profiles-daemon /var/service || true
  #powerprofilesctl set balanced || true
  sudo ln -s /etc/sv/tlp /var/service || true
else
  # This computer runs on power outlet
  #powerprofilesctl set performance || true
  echo "Desktop PC! Wow" || true
fi
