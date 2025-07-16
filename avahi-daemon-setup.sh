#!/bin/bash

set -e

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

echo "Installing avahi-daemon..."
apt-get update
apt-get install -y avahi-daemon

CONF_FILE="/etc/avahi/avahi-daemon.conf"

echo "Configuring avahi-daemon..."

# Backup the original config
cp "$CONF_FILE" "$CONF_FILE.bak.$(date +%s)"

# Function to uncomment and set a config key in the [server] section
set_config() {
  local key="$1"
  local value="$2"
  if grep -Eq "^[#;]?\s*${key}\s*=" "$CONF_FILE"; then
    sed -i "s|^[#;]\?\s*${key}\s*=.*|${key}=${value}|" "$CONF_FILE"
  else
    sed -i "/^\[server\]/a ${key}=${value}" "$CONF_FILE"
  fi
}

# Apply configuration changes
set_config "use-ipv6" "no"
set_config "publish-resolv-conf-dns-servers" "yes"
set_config "publish-aaaa-on-ipv4" "no"

echo "Restarting avahi-daemon..."
systemctl restart avahi-daemon
systemctl enable avahi-daemon

echo "Avahi-daemon installation and configuration complete."
