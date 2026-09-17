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
# Timings are written as the run goes, one line per step, and printed at the end.
# Kept because "the install takes twelve minutes" is not something to fix by
# guessing which part of it does.
TIMINGS=~/.local/state/omvoid/timings
mkdir -p "$(dirname "$TIMINGS")"
: >"$TIMINGS"

run_step() {
  local marker="$OMVOID_STATE/$1" started=$SECONDS
  if [ -f "$marker" ]; then
    echo "skip $1 (already done)"
    return 0
  fi
  source "$OMVOID_INSTALL/$1"
  mkdir -p "$(dirname "$marker")"
  touch "$marker"
  printf '%6d  %s\n' "$((SECONDS - started))" "$1" >>"$TIMINGS"
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
# Neither of these from the medium.
#
# "sudo -v" refuses to be satisfied by a NOPASSWD rule while an ordinary %wheel
# rule also matches the user -- it asks for a password regardless, and in a
# chroot there is nobody to type one, so install.sh died on its third line.
# Plain sudo is fine there: the wizard grants NOPASSWD for the whole run, and
# "sudo -n true" answers as root. Verified in the guest, not assumed.
#
# The keepalive is skipped for a second reason: a loop left running inside the
# chroot holds the target open, and the installer cannot unmount it afterwards.
if [[ -z ${OMVOID_IN_CHROOT:-} ]]; then
  sudo -v
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) &
fi

# Install prerequisites
run_step preflight/migrations.sh
run_step preflight/first-run-mode.sh
run_step preflight/update.sh
run_step preflight/gum.sh

# Configuration
show_logo
show_subtext "Let's install OMVOID! [1/5]"
# Sourced directly, never marker-gated: this step only exports variables, and a
# marker would make it skipped on a retry -- leaving every later step that uses
# them with nothing. install.sh offers a retry by name when it fails, so that
# path has to work.
source "$OMVOID_INSTALL/config/identification.sh"
run_step config/config.sh
run_step config/swap.sh
run_step config/xcompose.sh
run_step config/services.sh
run_step config/cron.sh
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
# First in this block, before anything installs from the other repositories.
# It used to sit after development.sh, which installs python3-pywal16 -- one of
# our own packages -- so on a machine that had not been through an omvoid install
# before, xbps knew only Void's repositories and the step died with "not found in
# repository pool". The image never showed it: there the wizard installs every
# package from the medium first, so the step has nothing left to look up.
run_step development/omvoid-repo.sh
run_step development/docker.sh
run_step development/mango.sh
run_step development/development.sh
run_step development/sddm.sh
run_step development/pipewire.sh
run_step development/mise.sh
run_step development/agent-skills.sh
# ЗАКОММЕНТИРОВАНО: node ставится через mise (см. development/mise.sh)
#run_step development/node.sh
run_step development/mihomo.sh
run_step development/mw.sh

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
run_step apps/vendored.sh
run_step apps/webapps.sh
run_step apps/xtras.sh
run_step apps/mimetypes.sh
run_step apps/record-deployed.sh

show_logo
show_subtext "Installing void-packages repo and building apps [5/5]"
#run_step apps/voidpackages.sh

# # Reboot
show_logo
echo "seconds per step, slowest first:"
sort -rn "$TIMINGS" | head -15
printf '%6d  total\n' "$SECONDS"
echo

show_subtext "We're done, you gorgeous!"
show_subtext "✨ 🌟 ✨"
# Last, on purpose: runit picks a service up within seconds, and sddm takes over
# the console. Enabled any earlier, the rest of the install would run behind a
# login screen.
#
# Through the helper rather than by linking into /var/service, which is a
# symlink into a tmpfs made at boot -- correct here, and pointing at nothing
# when the system is being built in a chroot.
omvoid-service-enable sddm
# Never from a chroot: /proc is the live system's, so "reboot" there restarts
# the machine that is still running the install, halfway through it. The wizard
# that started this run finishes the job and asks about rebooting itself.
if [[ -n ${OMVOID_IN_CHROOT:-} ]]; then
  echo "Done. The installer will finish up and offer to reboot."
elif gum confirm "Reboot now to finish?" 2>/dev/tty; then
  sudo reboot
else
  echo "Reboot skipped. Reboot manually when ready: sudo reboot"
fi
