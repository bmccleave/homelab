#!/bin/bash

set -e

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

# Update package list and install necessary packages
apt update
apt install -y openssh-server avahi-daemon net-tools iputils-ping

# Ensure netplan config uses DHCP for the primary interface
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
cat > $NETPLAN_CONFIG <<EOF
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: true
EOF
netplan apply

# Create a new user with passwordless sudo access
USERNAME="newuser"
PASSWORD="password"

# Add the user
useradd -m -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Grant passwordless sudo access
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

# Avahi-daemon configuration
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

# Start and enable services
systemctl enable ssh
systemctl start ssh
systemctl restart avahi-daemon
systemctl enable avahi-daemon

# Clean