#!/bin/bash


# Install mihomo (MetaCubeX) — not in Void repos, fetched from GitHub releases.
# The runit service is created but NOT linked into /var/service: enabling it is
# a manual step (ln -s /etc/sv/mihomo /var/service).

# The binary is a package now. It used to be resolved from the GitHub releases
# API and downloaded on every machine, which also meant every machine got
# whatever version happened to be current that day.
sudo xbps-install -y mihomo

# Config dir referenced by the service (left for the user to populate)
sudo mkdir -p /etc/mihomo

# Stub config so the service can start on a fresh box.
# Only written if no config exists yet — never clobber a real one.
if [ ! -e /etc/mihomo/config.yaml ]; then
  stub_tmp=$(mktemp)
  cat > "$stub_tmp" <<'EOF'
mixed-port: 7897
mode: rule
log-level: info
external-controller: 127.0.0.1:9090
secret: ""
external-ui: /etc/mihomo/ui
external-ui-url: https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip
dns:
  enable: true
  nameserver:
    - 1.1.1.1
    - 8.8.8.8
proxies: []
proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - DIRECT
rules:
  - MATCH,DIRECT
EOF
  sudo install -m 0644 "$stub_tmp" /etc/mihomo/config.yaml
  rm -f "$stub_tmp"
fi 

# Create runit service (not linked into /var/service — done by hand)
run_tmp=$(mktemp)
cat > "$run_tmp" <<'EOF'
#!/bin/sh
exec 2>&1
exec /usr/bin/mihomo -d /etc/mihomo
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
  # Said, not fatal. This step is sourced, so "exit" would end the whole
  # install over a convenience rule: without the file the menu asks for a
  # password, and nothing else about the machine is different.
  echo "mihomo: generated sudoers file is invalid — skipping it" >&2
fi
rm -f "$sudo_tmp"

echo "mihomo: installed. Enable with: omvoid-service-enable mihomo"
