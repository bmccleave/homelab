#!/bin/bash

set -e
DOMAIN="labregistry.local"
CA_DIR="$HOME/myCA"
HARBOR_VERSION="v2.13.1"

echo "=== [1] Check and install Docker + Docker Compose ==="
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

echo "=== [2] Download and extract Harbor installer ==="
wget -q https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-online-installer-${HARBOR_VERSION}.tgz
tar xzf harbor-online-installer-${HARBOR_VERSION}.tgz
cd harbor

echo "=== [3] Generate and sign certificate with local CA ==="
openssl genrsa -out $DOMAIN.key.pem 2048
openssl req -new -key $DOMAIN.key.pem -out $DOMAIN.csr.pem -subj "/CN=$DOMAIN"
e
if [ ! -f ../create-local-ca.sh ]; then
  echo "Missing create-local-ca.sh in parent directory."
  exit 1
fi

bash ../create-local-ca.sh "$DOMAIN"

cp $DOMAIN.cert.pem harbor.crt
cp $DOMAIN.key.pem harbor.key

echo "=== [4] Configure harbor.yml ==="
cp harbor.yml.tmpl harbor.yml
sed -i "s/^hostname:.*/hostname: $DOMAIN/" harbor.yml
sed -i '/^# https:/,+4 s/^# //' harbor.yml
sed -i "s|certificate: .*|certificate: ./harbor.crt|" harbor.yml
sed -i "s|private_key: .*|private_key: ./harbor.key|" harbor.yml

echo "=== [5] Install Harbor ==="
sudo ./install.sh

echo "=== [6] Optional: Add hostname to /etc/hosts ==="
if ! grep -q "$DOMAIN" /etc/hosts; then
  echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts
fi

echo "✅ Harbor is now running at https://$DOMAIN"
echo "🔐 Default credentials: admin / Harbor12345"
