#!/bin/bash

# Preflight sanity checks. Run on every invocation (not marker-gated) so the
# installer fails fast with a clear message instead of dying deep inside a step.

# Void Linux only
if ! command -v xbps-install >/dev/null 2>&1; then
  echo "OMVOID is a Void Linux installer, but xbps-install was not found. Aborting."
  exit 1
fi

# Must run as a normal user: dotfiles, group membership and the sudoers rules
# all target a real $USER. Running as root would scatter config into /root.
if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run OMVOID as root. Run as your normal user — it will sudo when needed."
  exit 1
fi

# Network reachable (the install pulls packages, git repos and web apps)
if ! curl -fsS --max-time 10 -o /dev/null https://github.com; then
  echo "No network connectivity to github.com. Check your connection and retry."
  exit 1
fi
