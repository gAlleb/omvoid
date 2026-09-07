#!/bin/sh
# No "set -eu" here. Steps under install/ are sourced, so the options land in
# the installer's own shell and stay on for every step after this one -- -u then
# turned the next step, xcompose.sh, into an "unbound variable" abort. install.sh
# already runs with -e for all of them.

SWAPFILE=/swapfile
SIZE_MB=4096

if [ ! -f "$SWAPFILE" ]; then
    sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SIZE_MB" status=progress
    sudo chmod 600 "$SWAPFILE"
    sudo mkswap "$SWAPFILE"
fi

grep -q "^$SWAPFILE " /etc/fstab || \
    printf '%s\n' "$SWAPFILE none swap defaults 0 0" | sudo tee -a /etc/fstab > /dev/null

swapon --show=NAME --noheadings | grep -qx "$SWAPFILE" || sudo swapon "$SWAPFILE"
