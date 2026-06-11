#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

export PATH="$HOME/.local/share/omvoid/bin:$PATH"
OMVOID_INSTALL=~/.local/share/omvoid/install
OMVOID_STATE=~/.local/state/omvoid/done

# Capture the whole run to a log so failures are reportable
mkdir -p ~/.local/state/omvoid
exec > >(tee -a ~/.local/state/omvoid/install.log) 2>&1

# Run an install step once. State lives outside the repo so install.sh is never
# mutated: a completed step leaves a marker and is skipped on a retry after a failure.
run_step() {
  local marker="$OMVOID_STATE/$1"
  if [ -f "$marker" ]; then
    echo "skip $1 (already done)"
    return 0
  fi
  source "$OMVOID_INSTALL/$1"
  mkdir -p "$(dirname "$marker")"
  touch "$marker"
}

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mOMVOID installation failed!\e[0m"
  echo "You can retry by running: bash ~/.local/share/omvoid/install.sh"
  echo "Log: ~/.local/state/omvoid/install.log"
}

trap catch_errors ERR

show_logo() {
  clear
  # tte -i ~/.local/share/omvoid/logo.txt --frame-rate ${2:-120} ${1:-expand}
  cat <~/.local/share/omvoid/logo.txt
  echo
}

show_subtext() {
  echo "$1" # | tte --frame-rate ${3:-640} ${2:-wipe}
  echo
}

# Preflight sanity checks (always run, never marker-gated)
source "$OMVOID_INSTALL/preflight/guard.sh"

# Cache sudo credentials and keep them alive for the whole run, so the install
# never stalls on a password prompt mid-step (which trap ERR would catch).
sudo -v
( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) &

# Install prerequisites
# run_step preflight/migrations.sh
run_step preflight/first-run-mode.sh
run_step preflight/update.sh
run_step preflight/gum.sh

# Configuration
show_logo
show_subtext "Let's install OMVOID! [1/5]"
run_step config/identification.sh
run_step config/config.sh
run_step config/xcompose.sh
run_step config/services.sh
run_step config/gpu.sh
#run_step config/runsvdir.sh
run_step config/runsvdir-local.sh
#run_step config/turnstile.sh
run_step config/groups.sh
run_step config/rclone.sh
run_step config/power.sh


# Development
show_logo
show_subtext "Installing terminal and main tools [2/5]"
run_step development/docker.sh
run_step development/mango.sh
run_step development/development.sh
run_step development/omvoid-repo.sh
run_step development/sddm.sh
run_step development/pipewire.sh
run_step development/node.sh
run_step development/mihomo.sh


# Desktop
show_logo
show_subtext "Installing desktop tools [3/5]"
run_step desktop/fonts.sh
run_step desktop/theme.sh

# # Apps
show_logo
show_subtext "Installing default applications [4/5]"
run_step apps/icons.sh
run_step apps/tui.sh
run_step apps/audioutils.sh
run_step apps/webapps.sh
run_step apps/xtras.sh
run_step apps/mimetypes.sh

show_logo
show_subtext "Installing void-packages repo and building apps [5/5]"
#run_step apps/voidpackages.sh

# # Reboot
show_logo
show_subtext "We're done, you gorgeous!"
show_subtext "✨ 🌟 ✨"
if [ ! -L "/var/service/sddm" ]; then
  sudo ln -s /etc/sv/sddm /var/service
fi
if gum confirm "Reboot now to finish?"; then
  sudo reboot
else
  echo "Reboot skipped. Reboot manually when ready: sudo reboot"
fi
