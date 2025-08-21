#!/bin/sh
mkdir -p ~/.config/service/
sudo mkdir /etc/sv/runsvdir-$USER


sudo tee /etc/sv/runsvdir-$USER/run <<'EOF'
#!/bin/sh

export USER="__USERNAME__"
export HOME="/home/__USERNAME__"

groups="$(id -Gn "$USER" | tr ' ' ':')"
svdir="$HOME/.config/service"

exec chpst -u "$USER:$groups" runsvdir "$svdir"
EOF

sudo sed -i "s/__USERNAME__/$USER/g"  /etc/sv/runsvdir-$USER/run

sudo chmod +x /etc/sv/runsvdir-$USER/run

echo "File '/etc/sv/runsvdir-$USER/run' created and made executable."

sudo tee /etc/sv/runsvdir-$USER/finish <<'EOF'
#!/bin/sh
sv -w600 force-stop /home/__USERNAME__/.config/service/*
exit /home/__USERNAME__/.config/service/*
EOF

sudo sed -i "s/__USERNAME__/$USER/g"  /etc/sv/runsvdir-$USER/finish

sudo chmod +x /etc/sv/runsvdir-$USER/finish

echo "File '/etc/sv/runsvdir-$USER/finish' created and made executable."

sudo ln -s /etc/sv/runsvdir-$USER /var/service/

echo "Per-user service is enabled"
