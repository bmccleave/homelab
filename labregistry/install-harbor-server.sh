#!/bin/bash

set -e

HARBOR_DIR="harbor"
HARBOR_YML="harbor.yml"
REGISTRY_NAME="labregistry.local"
CERT_DIR="/etc/docker/certs.d/$REGISTRY_NAME"
CA_BASE_DIR="$HOME/myCA"
CA_CERT="$CA_BASE_DIR/certs/ca.cert.pem"
REG_CERT="./$REGISTRY_NAME.cert.pem"
REG_KEY="./$REGISTRY_NAME.key.pem"

echo "[Step 1]: Generating local CA and certificates using create-local-ca.sh ..."
if [ ! -f ./create-local-ca.sh ]; then
    echo "✖ create-local-ca.sh script not found in current directory."
    exit 1
fi
chmod +x ./create-local-ca.sh
./create-local-ca.sh

echo "[Step 2]: Copying certificates to Docker and Harbor locations ..."
sudo mkdir -p "$CERT_DIR"
sudo cp "$CA_CERT" "$CERT_DIR/ca.crt"
sudo cp "$REG_CERT" "$CERT_DIR/tls.crt"
sudo cp "$REG_KEY" "$CERT_DIR/tls.key"

echo "[Step 3]: Downloading Harbor installer if not present..."
HARBOR_TAG=$(curl -s https://api.github.com/repos/goharbor/harbor/releases/latest | grep tag_name | cut -d '"' -f4)
echo "Latest Harbor tag: $HARBOR_TAG"
HARBOR_TARBALL="harbor-online-installer-${HARBOR_TAG}.tgz"
if [ ! -f "$HARBOR_TARBALL" ]; then
    wget "https://github.com/goharbor/harbor/releases/download/${HARBOR_TAG}/harbor-online-installer-${HARBOR_TAG}.tgz" -O "$HARBOR_TARBALL"
fi

echo "[Step 4]: Extracting Harbor installer..."
tar -xzvf "$HARBOR_TARBALL"

cd "$HARBOR_DIR" || {
    echo "✖ Failed to enter Harbor directory."
    exit 1
}

echo "[Step 5]: Preparing Harbor configuration..."
cp harbor.yml.tmpl "$HARBOR_YML"

# Remove all other https blocks except the one after hostname
sed -i '/^https:/,/^[^ ]/d' "$HARBOR_YML"

# Set hostname in harbor.yml
sed -i "s/^hostname:.*/hostname: $REGISTRY_NAME/" "$HARBOR_YML"

# Insert correct https block after hostname (for Harbor v2.13.x)
sed -i "/^hostname:/a https:\n  port: 443\n  certificate: $CERT_DIR/tls.crt\n  private_key: $CERT_DIR/tls.key" "$HARBOR_YML"

echo "[Step 6]: Installing Harbor..."
sudo ./install.sh

echo "✅ Harbor installation and TLS setup completed successfully!"
