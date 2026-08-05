#!/bin/bash

# Setup trim job
sudo tee /etc/cron.weekly/fstrim > /dev/null <<'EOF'
#!/bin/sh
exec /usr/bin/fstrim -a
EOF
sudo chmod +x /etc/cron.weekly/fstrim
