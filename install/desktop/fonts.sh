# Fonts.
#
# The families that are not in Void come from omvoid's own repository as
# packages. They used to be five tarballs fetched from GitHub releases and
# unpacked into ~/.local/share/fonts on every machine -- around ten minutes of
# an install, for files that are identical everywhere and never change.
#
# Noto Nerd Font is deliberately absent: its package comes to 142 MB and GitHub
# refuses files over 100 MB, so it cannot live in the repository with the rest.

sudo xbps-install -y noto-fonts-ttf noto-fonts-ttf-extra liberation-fonts-ttf \
  noto-fonts-emoji fonts-roboto-ttf dejavu-fonts-ttf noto-fonts-cjk \
  nerd-fonts-symbols-ttf nerd-fonts-caskaydia-ttf nerd-fonts-jetbrains-ttf \
  nerd-fonts-firacode-ttf sf-pro-display

# No "fc-cache -f" here. Every package above declares font_dirs, so xbps rebuilds
# the cache itself at the end of the transaction -- that is what all those
# "Updating fontconfig's cache" lines in the install log are. The call was left
# over from when the families were tarballs unpacked by hand into
# ~/.local/share/fonts, where no trigger could reach them, and -f is not free: it
# forces every cache to be rebuilt from scratch. The per-user cache fontconfig
# builds on its own the first time an application asks for a font.

# Rendering. Each of these is a fontconfig default that Void ships but does not
# enable.
for conf in 11-lcdfilter-default 10-hinting-slight 10-sub-pixel-rgb 50-user \
  60-latin 70-no-bitmaps-except-emoji; do
  if [[ -f /usr/share/fontconfig/conf.avail/$conf.conf ]]; then
    sudo ln -sf "/usr/share/fontconfig/conf.avail/$conf.conf" /etc/fonts/conf.d/
  fi
done
