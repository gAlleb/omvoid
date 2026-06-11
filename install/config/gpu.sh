#!/bin/bash

# Hardware video acceleration drivers, picked by detected GPU vendor.

GPU=$(lspci | grep -iE 'vga|3d|display' || true)

# Intel: HD Graphics/Xe/Iris use intel-media-driver; older GMA uses libva-intel-driver
if echo "$GPU" | grep -qi 'intel'; then
  if [[ "${GPU,,}" =~ "gma" ]]; then
    sudo xbps-install -y libva-intel-driver
  else
    sudo xbps-install -y intel-media-driver
  fi
fi

# AMD/ATI: Mesa Gallium drivers cover VA-API and VDPAU
if echo "$GPU" | grep -qiE 'amd|ati|radeon'; then
  sudo xbps-install -y mesa-vaapi libvdpau-va-gl
fi

# NVIDIA: proprietary driver lives in the nonfree repo and needs manual setup
if echo "$GPU" | grep -qi 'nvidia'; then
  echo "NVIDIA GPU detected — driver setup is left to you (nonfree repo required)."
  echo "See https://docs.voidlinux.org/config/graphical-session/gpu/nvidia.html"
fi
