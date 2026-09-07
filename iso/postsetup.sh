#!/bin/bash

# Puts onto the live medium everything the installer needs.
#
# mklive.sh calls this on the HOST once the image root is populated, passing its
# path -- not inside a chroot.
#
# What goes on the medium is deliberately small: the package mirror, omvoid
# itself, and the installer. Nothing is configured here. A machine is configured
# by omvoid's own install.sh, which the installer runs inside the new system --
# so there is one description of an omvoid system instead of two.
#
# This used to bake fonts, themes, /etc/skel and a great deal else into the
# image. That was the wrong shape: it made the image a second source of truth,
# and everything install.sh does beyond installing packages simply never
# happened on a machine installed from it.

set -uo pipefail

ROOTFS="${1:?usage: postsetup.sh <rootfs>}"
OMVOID_PATH=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)
MIRROR="${OMVOID_MIRROR:-$HOME/.cache/omvoid/mirror}"

# Kept between builds: the tmux plugin checkouts below are small but there is no
# reason to clone them again every time.
CACHE="${OMVOID_ISO_CACHE:-/var/cache/omvoid-iso}"
mkdir -p "$CACHE"

step() { printf '\n>>> %s\n' "$*"; }
warn() { printf '    !! %s\n' "$*" >&2; }

# --- the package mirror -------------------------------------------------------
#
# The whole reason an install needs no network. Built beforehand by
# omvoid-pkg-mirror, deliberately: refreshing it is when the image's package
# versions get chosen.

step "package mirror"
if [[ ! -d $MIRROR ]] || ! compgen -G "$MIRROR/*.xbps" >/dev/null; then
  warn "no mirror at $MIRROR — run omvoid-pkg-mirror first"
  warn "the image will boot, but its installer will have nothing to install"
else
  mkdir -p "$ROOTFS/var/cache/omvoid"
  cp -a "$MIRROR" "$ROOTFS/var/cache/omvoid/mirror"
  count=$(ls -1 "$ROOTFS/var/cache/omvoid/mirror"/*.xbps 2>/dev/null | wc -l)
  echo "    $count packages, $(du -sh "$MIRROR" | cut -f1)"
fi

# --- omvoid itself ------------------------------------------------------------
#
# With its .git: the installer copies this into the new user's home, and omvoid
# updates itself by pulling. A checkout stripped of its history is a dead end.

step "omvoid"
install -d "$ROOTFS/usr/local/share/omvoid"
cp -a "$OMVOID_PATH" "$ROOTFS/usr/local/share/omvoid/repo"

# --- tmux plugins -------------------------------------------------------------
#
# tpm and the plugins tmux.conf names are git checkouts, cloned by
# install/config/config.sh. Offline that step would fail twice over -- once for
# the manager, then once per plugin -- so the medium carries them, the same way
# it carries packages.
#
# Cloned from the plugin lines in the repository's own tmux.conf, so adding a
# plugin there is all that is needed; there is no second list.

step "tmux plugins"
plugins_dir="$CACHE/tmux-plugins"
mkdir -p "$plugins_dir"

clone_plugin() {
  local repo="$1" name="${1##*/}"
  if [[ -d $plugins_dir/$name/.git ]]; then
    git -C "$plugins_dir/$name" fetch --quiet --depth 1 2>/dev/null &&
      git -C "$plugins_dir/$name" reset --quiet --hard @{u} 2>/dev/null
    echo "    $name from cache"
  else
    git clone --quiet --depth 1 "https://github.com/$repo" "$plugins_dir/$name" &&
      echo "    $name" || warn "$name could not be cloned"
  fi
}

clone_plugin "tmux-plugins/tpm"
while read -r repo; do
  [[ -n $repo ]] && clone_plugin "$repo"
done < <(grep -oP "^\s*set -g @plugin '\K[^']+" "$OMVOID_PATH/config/tmux/tmux.conf" 2>/dev/null |
  grep -v '^tmux-plugins/tpm$')

if compgen -G "$plugins_dir/*" >/dev/null; then
  install -d "$ROOTFS/usr/local/share/omvoid"
  cp -a "$plugins_dir" "$ROOTFS/usr/local/share/omvoid/tmux-plugins"
fi

# --- the installer ------------------------------------------------------------

step "installer"
install -Dm755 "$OMVOID_PATH/bin/omvoid-install" "$ROOTFS/usr/local/bin/omvoid-install"
install -Dm755 "$OMVOID_PATH/bin/omvoid-iso-packages" "$ROOTFS/usr/local/bin/omvoid-iso-packages"
install -Dm644 "$OMVOID_PATH/logo.txt" "$ROOTFS/usr/local/share/omvoid/logo.txt"

# omvoid-iso-packages reads the package list out of the repository, so it needs
# to know where that repository is on the medium.
sed -i 's|OMVOID_PATH="${OMVOID_PATH:-$HOME/.local/share/omvoid}"|OMVOID_PATH="${OMVOID_PATH:-/usr/local/share/omvoid/repo}"|' \
  "$ROOTFS/usr/local/bin/omvoid-iso-packages"

# Started on its own, on the first console. Telling someone to type a command is
# a step that can be got wrong; this is the only thing the medium is for.
#
# Two halves, and the first was missing: a login shell only runs .bash_profile
# once somebody logs in, and the live medium sits at "void-live login:" until
# they do. agetty is told to log root in by itself on tty1 -- which is what
# archiso does for Omarchy, and the reason their installer appears unaided.
if [[ -f $ROOTFS/etc/sv/agetty-tty1/conf ]]; then
  sed -i 's|GETTY_ARGS="--noclear"|GETTY_ARGS="--noclear --autologin root"|' \
    "$ROOTFS/etc/sv/agetty-tty1/conf"
  grep -q -- '--autologin root' "$ROOTFS/etc/sv/agetty-tty1/conf" &&
    echo "    autologin on tty1" ||
    warn "could not set autologin — the installer will need a login first"
fi

cat >>"$ROOTFS/root/.bash_profile" <<'EOF'

# The installer runs by itself on the first console. Anywhere else this is a
# normal root shell, so a second terminal is still usable for looking around.
if [[ $(tty) == /dev/tty1 && -z ${OMVOID_INSTALL_STARTED:-} ]]; then
  export OMVOID_INSTALL_STARTED=1
  omvoid-install
fi
EOF

# The live system prints this at every console, telling the person to run
# void-installer -- not the one we want them to reach for.
if [[ -f $ROOTFS/etc/issue ]]; then
  sed -i 's|# void-installer|# omvoid-install|; s|To start the installation please type:|To install OMVOID please type:|' \
    "$ROOTFS/etc/issue"
fi

step "done"
