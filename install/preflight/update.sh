#!/bin/bash

# On Void, update the package manager itself before a full system update —
# a stale xbps (common on older install ISOs) can otherwise fail mid-sync.
sudo xbps-install -Suy xbps
sudo xbps-install -Suy
