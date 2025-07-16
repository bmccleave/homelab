#!/bin/bash

set -e
DOMAIN="labregistry.local"
CA_CERT="ca.cert.pem"  # This should be copied from Harbor VM (via SCP or shared folder)

if [ ! -f "$CA_CERT" ]; then
  echo "Missing $CA_CERT – copy it from the Harbor VM (~/myCA/certs/ca.cert.pem)"
  exit 1
fi

echo "=== [1] Trust CA system-wide ==="
sudo cp "$CA_CERT" /usr/local/share/ca-certificates/myhomeCA.crt
sudo update-ca-certificates

echo "=== [2] Configure Docker trust ==="
sudo mkdir -p /etc/docker/certs.d/$DOMAIN
sudo cp "$CA_CERT" /etc/docker/certs.d/$DOMAIN/ca.crt
sudo systemctl restart docker

echo "=== [3] Optional: Add to /etc/hosts ==="
read -p "Enter IP of Harbor VM: " HARBOR_IP
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "$HARBOR_IP  $DOMAIN" | sudo tee -a /etc/hosts
fi

echo "✅ This machine now trusts $DOMAIN for Docker and system-wide HTTPS"
