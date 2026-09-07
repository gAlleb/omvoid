# Repositories omvoid installs from, and their keys.
#
# All three in one place, read from install/lib/sources.sh. They used to be
# three steps with the addresses written out by hand, and they had already
# drifted: one of them named the repository with different capitalisation than
# the others.
#
# The key for each has to be in place before xbps will take anything from that
# repository -- otherwise it asks whether to trust a fingerprint, and an
# unattended install has nobody to answer.
#
# Signing and publishing omvoid's own packages, for reference:
#   omvoid-pkg-build <name>...
#   omvoid-pkg-publish

source "$OMVOID_INSTALL/lib/sources.sh"

sudo mkdir -p /var/db/xbps/keys /etc/xbps.d

# Keys first, for every repository including the deferred ones: a key costs
# nothing and the machine needs it the first time it updates.
for conf in "${!XBPS_REPOS[@]}"; do
  keydir="${XBPS_REPO_KEYS[$conf]:-}"
  if [[ -n $keydir && -d ~/.local/share/omvoid/default/repokeyes/$keydir ]]; then
    sudo cp -R ~/.local/share/omvoid/default/repokeyes/"$keydir"/* /var/db/xbps/keys/
  else
    echo "omvoid-repo: no key directory for $conf — xbps will ask about its fingerprint"
  fi
done

# Then the configuration -- but only for the repositories the sync below can
# actually reach. A deferred one written now would be part of that sync, and one
# unreachable repository is enough to stop the whole install.
for conf in "${!XBPS_REPOS[@]}"; do
  [[ -n ${XBPS_REPOS_DEFERRED[$conf]:-} ]] && continue
  echo "repository=${XBPS_REPOS[$conf]}" | sudo tee "/etc/xbps.d/$conf.conf" >/dev/null
  echo "repository: $conf"
done

# One sync, here, because these repositories were unknown a moment ago and
# nothing can be installed from an index that has not been fetched. The steps
# that install brave and noctalia then need no sync of their own -- syncing once
# per package would fetch the same indexes over and over.
#
# Skipped when the system is being built inside a chroot: everything is already
# on the medium, and syncing would reach over a network that may not be there.
# repo.voiders.dev in particular does not refuse -- it redirects and then goes
# quiet, which has hung a build for a quarter of an hour. The configuration
# above is still written, so the installed machine updates from them normally.
if [[ -z ${OMVOID_IN_CHROOT:-} ]]; then
  sudo xbps-install -S
else
  echo "repositories: configured, sync left for the installed system"
fi

# The deferred ones last, after the sync they would have broken. The machine
# gets them; this install simply never asks them for anything.
for conf in "${!XBPS_REPOS_DEFERRED[@]}"; do
  [[ -n ${XBPS_REPOS[$conf]:-} ]] || continue
  echo "repository=${XBPS_REPOS[$conf]}" | sudo tee "/etc/xbps.d/$conf.conf" >/dev/null
  echo "repository: $conf (configured, not synced — needs the proxy)"
done
