# External sources omvoid still fetches at install time, in one place.
#
# Read by the install steps and by iso/postsetup.sh, so a change reaches both an
# ordinary install and the image.
#
# Much shorter than it was. Fonts, the WhiteSur themes, wal-telegram,
# mutt-wizard, the sddm theme and the mihomo binary all used to be listed here
# and fetched on every machine; they are xbps packages now, and their sources
# live in their templates under srcpkgs/. What remains is what is not a package.
#
# Data only. No commands: this file is sourced, and anything run here would run
# once per step that sources it.

# name -> repository. The name is also the directory each is cloned into.
declare -A GIT_SOURCES=(
  # The tmux plugin manager expects to be a checkout in the user's config: it
  # updates itself and installs plugins into its own directory, which is not
  # something a package can own.
  [tpm]="https://github.com/tmux-plugins/tpm"

  # PhotoGIMP is not installed any more. Left as a comment rather than deleted
  # so it is clear it was a choice.
  # [PhotoGIMP]="https://github.com/Diolinux/PhotoGIMP.git"
)

# Third-party xbps repositories. The key for each lives in
# default/repokeyes/<key dir>/ and is copied to /var/db/xbps/keys, or xbps
# refuses the packages as unsigned.
#
# file in /etc/xbps.d -> repository URL
declare -A XBPS_REPOS=(
  [jake-void-repo]="https://codeberg.org/JakeAtLinux/void-repo/raw/branch/main/x86_64"
  # The address the redirect leads to, not repo.voiders.dev itself.
  #
  # repo.voiders.dev answers every request with a 302 to the git forge below,
  # and xbps does not survive it: the connection stays open and nothing arrives.
  # It has hung an image build for a quarter of an hour and a mirror build for
  # seven minutes. The same file over the direct address comes back in a third
  # of a second.
  [10-voiders-community]="https://git.voiders.dev/voiders-community/repository/raw/branch/binpkgs"
  [omvoid]="https://raw.githubusercontent.com/gAlleb/omvoid-repo/repository-x86_64-glibc"
)

# Repositories that must not be synced while the install runs.
#
# git.voiders.dev is not reachable from every network -- that is part of what
# mihomo is for -- and mihomo is installed later than this step and is not
# running during the install at all. The sync does not fail quickly either: the
# connection is accepted and then nothing arrives, which has hung a build for a
# quarter of an hour and a mirror for seven minutes.
#
# The configuration is still written, so the installed machine updates from it
# normally once the proxy is up. Nothing installed here comes from it: brave
# comes from jake-void-repo, noctalia from omvoid's own.
declare -A XBPS_REPOS_DEFERRED=(
  [10-voiders-community]=1
)

# Which key directory belongs to which repository file.
declare -A XBPS_REPO_KEYS=(
  [jake-void-repo]="jake"
  [10-voiders-community]="noctalia"
  [omvoid]="omvoid"
)

# Their templates, kept for reference only.
#
# omvoid does not build these: the people who maintain them follow the releases,
# and we take their packages as published. The templates sit in srcpkgs/ so it
# is possible to see how a package is made without going to look for it, and
# omvoid-pkg-build never touches them -- it builds only what it is told to.
#
#   brave-origin-bin  https://codeberg.org/JakeAtLinux/void-repo
#   noctalia          https://git.voiders.dev/voiders-community/repository

# --- what used to be fetched here ---------------------------------------------
#
# Kept as a note. Each of these was downloaded and unpacked or built on every
# machine, and together they were most of an install's running time. They are
# xbps packages now; their sources are in the templates under srcpkgs/, and the
# built packages come from the omvoid repository above.
#
#   fonts, unpacked into ~/.local/share/fonts:
#     .../nerd-fonts/releases/download/v3.4.0/CascadiaMono.tar.xz
#     .../nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz
#     .../nerd-fonts/releases/download/v3.4.0/FiraCode.tar.xz
#     .../nerd-fonts/releases/download/v3.4.0/Noto.tar.xz      -- dropped: 142 MB
#     .../gAlleb/SFProDisplay/releases/download/v1.0.0/SFProDisplay.tar.xz
#
#   cloned and run through their own installers:
#     https://github.com/vinceliuice/WhiteSur-gtk-theme.git
#     https://github.com/vinceliuice/WhiteSur-icon-theme.git
#     https://github.com/vinceliuice/WhiteSur-kde
#     https://github.com/keyitdev/sddm-astronaut-theme.git
#
#   cloned and "make install"-ed straight into /usr:
#     https://github.com/galleb/wal-telegram
#     https://github.com/lukesmithxyz/mutt-wizard
#
#   resolved from the GitHub API and downloaded as a binary, so every machine
#   got whichever version was current that day:
#     https://api.github.com/repos/MetaCubeX/mihomo/releases/latest
