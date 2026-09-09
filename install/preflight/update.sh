#!/bin/bash

# On Void, update the package manager itself before a full system update —
# a stale xbps (common on older install ISOs) can otherwise fail mid-sync.
# Not from the medium. The base system there carries Void's own repositories in
# /usr/share/xbps.d, so "-Suy" reaches for the network even though everything was
# just installed from the mirror -- and upgrades past the versions the image was
# built and tested with, which is the opposite of what the mirror is for.
if [ -n "${OMVOID_IN_CHROOT:-}" ]; then
  echo "update: skipped — the packages came from the medium"
else
  sudo xbps-install -Suy xbps
  sudo xbps-install -Suy
fi
