#!/bin/bash

set -e

echo "[Step 1]: Updating package index..."
sudo apt update

echo "[Step 2]: Installing required packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "[Step 3]: Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "[Step 4]: Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[Step 5]: Updating package index (Docker repo)..."
sudo apt update

echo "[Step 6]: Installing Docker Engine, CLI, and containerd..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[Step 7]: Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "✅ Docker installation complete. Please log out and log back in for group changes to take effect."

