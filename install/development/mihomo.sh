#!/bin/bash

# Install mihomo (MetaCubeX) — not in Void repos, fetched from GitHub releases.
# The runit service is created but NOT linked into /var/service: enabling it is
# a manual step (ln -s /etc/sv/mihomo /var/service).

sudo xbps-install -y curl

# Pick the right "compatible" asset (max CPU compatibility) for this arch
case "$(uname -m)" in
  x86_64) ASSET_RE='mihomo-linux-amd64-compatible-v[0-9][^"]*\.gz' ;;
  aarch64) ASSET_RE='mihomo-linux-arm64-v[0-9][^"]*\.gz' ;;
  *) echo "mihomo: unsupported architecture $(uname -m)"; exit 1 ;;
esac

# Resolve the latest release asset URL from the GitHub API
URL=$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" \
  | grep -oE "https://[^\"]*${ASSET_RE}" \
  | head -n1)

if [ -z "$URL" ]; then
  echo "mihomo: could not find latest release asset"
  exit 1
fi

echo "mihomo: downloading $URL"
tmp=$(mktemp -d)
curl -fsSL "$URL" -o "$tmp/mihomo.gz"
gunzip "$tmp/mihomo.gz"
sudo install -m 0755 "$tmp/mihomo" /usr/local/bin/mihomo
rm -rf "$tmp"

# Config dir referenced by the service (left for the user to populate)
sudo mkdir -p /etc/mihomo

# Create runit service (not linked into /var/service — done by hand)
run_tmp=$(mktemp)
cat > "$run_tmp" <<'EOF'
#!/bin/sh
exec 2>&1
exec /usr/local/bin/mihomo -d /opt/clashtui/mihomo/config
EOF
sudo mkdir -p /etc/sv/mihomo
sudo install -m 0755 "$run_tmp" /etc/sv/mihomo/run
rm -f "$run_tmp"

# Passwordless service control + config symlinking for the omvoid-cmd-mihomo menu.
# Validate with visudo before installing so a typo can never lock sudo on the box.
sudo_tmp=$(mktemp)
cat > "$sudo_tmp" <<EOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/sv * mihomo
$USER ALL=(ALL) NOPASSWD: /usr/bin/ln -sf /etc/mihomo/*
EOF
if sudo visudo -cf "$sudo_tmp" >/dev/null; then
  sudo install -m 0440 -o root -g root "$sudo_tmp" /etc/sudoers.d/omvoid-mihomo
else
  echo "mihomo: generated sudoers file is invalid, aborting"
  rm -f "$sudo_tmp"
  exit 1
fi
rm -f "$sudo_tmp"

echo "mihomo: installed. Enable with: sudo ln -s /etc/sv/mihomo /var/service"
