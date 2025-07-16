#!/bin/bash

set -e

HARBOR_DIR="harbor"
HARBOR_TARBALL="harbor-online-installer-*.tgz"
HARBOR_YML="harbor.yml"
REGISTRY_NAME="labregistry.local"

CERT_DIR="/etc/docker/certs.d/$REGISTRY_NAME"
LOCAL_CA_DIR="~/local-ca"   # Assuming create-local-ca.sh uses this location


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


if command -v docker-compose &>/dev/null; then
    docker-compose version
elif docker compose version &>/dev/null; then
    docker compose version
else
    echo "✖ Docker Compose not found."
    echo "Install plugin with:"
    echo "  mkdir -p ~/.docker/cli-plugins/"
    echo "  curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose"
    echo "  chmod +x ~/.docker/cli-plugins/docker-compose"
    exit 1
fi

echo "[Step 3]: Generating local CA and certificates using create-local-ca.sh ..."
if [ ! -f ./create-local-ca.sh ]; then
    echo "✖ create-local-ca.sh script not found in current directory."
    exit 1
fi

chmod +x ./create-local-ca.sh
./create-local-ca.sh

echo "[Step 4]: Copying certificates to Docker and Harbor locations ..."

# Make sure cert dir exists
mkdir -p "$CERT_DIR"

# Copy CA cert
cp "$LOCAL_CA_DIR/ca.pem" "$CERT_DIR/ca.crt"
# Copy registry TLS cert and key issued by local CA
cp "$LOCAL_CA_DIR/$REGISTRY_NAME.pem" "$CERT_DIR/tls.crt"
cp "$LOCAL_CA_DIR/$REGISTRY_NAME-key.pem" "$CERT_DIR/tls.key"

echo "[Step 5]: Extracting Harbor installer..."
tar -xzvf $HARBOR_TARBALL

cd "$HARBOR_DIR" || {
    echo "✖ Failed to enter Harbor directory."
    exit 1
}

echo "[Step 6]: Preparing Harbor configuration..."
cp harbor.yml.tmpl "$HARBOR_YML"

echo "[Step 7]: Patching Harbor config for TLS and hostname ..."

sed -i "s/^hostname:.*/hostname: $REGISTRY_NAME/" "$HARBOR_YML"

# Add TLS config (indented properly for YAML)
sed -i "/^hostname:/a https:\n  port: 443\n  certificate: $CERT_DIR/tls.crt\n  private_key: $CERT_DIR/tls.key" "$HARBOR_YML"

echo "[Step 8]: Installing Harbor..."
./install.sh

echo "✅ Harbor installation and TLS setup complete."
