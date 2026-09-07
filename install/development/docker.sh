sudo xbps-install -y docker docker-compose docker-buildx docker-cli
# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"3"}}' | sudo tee /etc/docker/daemon.json
omvoid-service-enable docker
sudo usermod -aG docker $USER 
