#!/bin/sh
# Swap.
#
# No "set -eu" here. Steps under install/ are sourced, so the options land in
# the installer's own shell and stay on for every step after this one -- -u then
# turned the next step, xcompose.sh, into an "unbound variable" abort. install.sh
# already runs with -e for all of them.
#
# A swap partition, when there is one, makes a swap file pointless. Deciding that
# is easy on a running machine and impossible inside a chroot: the kernel is
# shared, so "swapon --show" there reports the live system's swap, not the one
# being installed. From the medium the answer therefore comes from the installer,
# which knows what it partitioned; interactively it is asked.

SWAPFILE=/swapfile
ANSWERS="$HOME/.local/state/omvoid/install-answers"

# What the installer decided, if it decided anything. OMVOID_SWAP_MB=0 means the
# machine has a swap partition, or swap was declined.
[ -f "$ANSWERS" ] && . "$ANSWERS"

swap_partition_present() {
  if [ -n "${OMVOID_IN_CHROOT:-}" ]; then
    # The target's own fstab is the only thing worth believing here.
    grep -qE '^[^#].*[[:space:]]swap[[:space:]]' /etc/fstab 2>/dev/null &&
      ! grep -qE "^$SWAPFILE[[:space:]]" /etc/fstab 2>/dev/null
  else
    swapon --show=TYPE --noheadings 2>/dev/null | grep -qx partition
  fi
}

if swap_partition_present; then
  echo "swap: a swap partition is in use, no swap file needed"
  return 0 2>/dev/null || exit 0
fi

current_mb=0
[ -f "$SWAPFILE" ] && current_mb=$(($(stat -c %s "$SWAPFILE") / 1024 / 1024))

if [ -n "${OMVOID_IN_CHROOT:-}" ]; then
  # Nobody to ask. 4 GiB unless the installer said otherwise.
  size_mb="${OMVOID_SWAP_MB:-4096}"
elif [ "$current_mb" -gt 0 ]; then
  echo "swap: a $((current_mb / 1024)) GiB swap file is already here"
  if gum confirm "Keep the swap file as it is?" 2>/dev/tty; then
    size_mb="$current_mb"
  else
    size_mb=$(($(gum input --prompt "New size in GiB: " --value "$((current_mb / 1024))" 2>/dev/tty) * 1024))
  fi
else
  if gum confirm "No swap partition. Create a swap file?" 2>/dev/tty; then
    size_mb=$(($(gum input --prompt "Size in GiB: " --value 4 2>/dev/tty) * 1024))
  else
    size_mb=0
  fi
fi

if [ "${size_mb:-0}" -le 0 ]; then
  echo "swap: none"
  return 0 2>/dev/null || exit 0
fi

if [ "$current_mb" -ne "$size_mb" ]; then
  # Only on a running system: swapoff inside a chroot would act on the host.
  [ -z "${OMVOID_IN_CHROOT:-}" ] && [ -f "$SWAPFILE" ] &&
    sudo swapoff "$SWAPFILE" 2>/dev/null
  sudo rm -f "$SWAPFILE"
  sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$size_mb" status=progress
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
fi

grep -q "^$SWAPFILE " /etc/fstab ||
  printf '%s\n' "$SWAPFILE none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null

# Not from the medium: the file belongs to a system that is not running yet, and
# swapon here would attach it to the live one instead -- which then holds the
# target open while the installer tries to unmount it.
if [ -z "${OMVOID_IN_CHROOT:-}" ]; then
  swapon --show=NAME --noheadings | grep -qx "$SWAPFILE" || sudo swapon "$SWAPFILE"
fi
