# Harbor Registry Setup

Automated deployment scripts for [Harbor](https://goharbor.io/) container registry with TLS certificate management for homelab environments.

## Overview

This directory contains automation scripts for deploying a production-ready Harbor container registry on Ubuntu, complete with a self-signed Certificate Authority (CA) and TLS certificate configuration. Client trust configuration scripts are provided for both Windows and Linux platforms.

## Prerequisites

- Ubuntu Server (tested on latest LTS)
- Minimum 2GB RAM, 20GB disk space
- Root or sudo access
- Internet connectivity for package downloads

## Features

- **Automated Installation**: Complete Harbor setup with minimal user intervention
- **Certificate Management**: Local CA creation and certificate signing using OpenSSL
- **TLS Security**: HTTPS-enabled Harbor registry with custom certificates
- **Multi-Platform Support**: Client trust scripts for Windows (PowerShell) and Linux (bash)
- **Docker Integration**: Automated Docker Engine installation and configuration

## Installation

### Server Setup (Ubuntu)

Execute the following scripts in order on your Ubuntu server:

#### 1. Install Docker Engine
```bash
./install-docker.sh
```
Installs Docker CE, Docker Compose plugin, and configures the current user for passwordless Docker access.

**Note:** Log out and back in after installation for group changes to take effect.

#### 2. Deploy Harbor with TLS
```bash
./install-harbor-server.sh
```
Performs the following operations:
- Generates a local Certificate Authority (CA)
- Creates TLS certificates for the registry domain (`labregistry.local` by default)
- Downloads and installs the latest Harbor release
- Configures Harbor with TLS encryption
- Starts Harbor services

### Client Configuration

After server deployment, configure client machines to trust the Harbor registry.

#### Linux Clients
```bash
./trust-harbor-client.sh
```
- Installs the CA certificate system-wide
- Configures Docker daemon to trust the registry
- Optionally adds `/etc/hosts` entry

**Prerequisites:** Copy `ca.cert.pem` from the server (`~/myCA/certs/ca.cert.pem`) to the client machine before running.

#### Windows Clients
```powershell
# Run PowerShell as Administrator
.\trust-harbor-client.ps1
```
- Imports CA certificate into Windows Trusted Root Certification Authorities
- Configures Docker Desktop to trust the registry

**Prerequisites:** Copy `ca.cert.pem` from the server to the Windows client before running.

## Configuration

### Custom Domain Name

To use a custom domain instead of the default `labregistry.local`:

```bash
./create-local-ca.sh your-custom-domain.local
```

Update the `REGISTRY_NAME` variable in `install-harbor-server.sh` accordingly.

### Optional: mDNS Hostname Resolution

For automatic hostname resolution on the local network:

```bash
# From parent directory
../avahi-daemon-setup.sh
```

**Note:** System reboot required after installation.

## Scripts Reference

| Script | Purpose | Requires Root |
|--------|---------|---------------|
| `create-local-ca.sh` | Generate local CA and sign certificates | No |
| `install-docker.sh` | Install Docker Engine and plugins | Yes (sudo) |
| `install-harbor-server.sh` | Deploy Harbor with TLS configuration | Yes (sudo) |
| `trust-harbor-client.sh` | Configure Linux client trust | Yes (sudo) |
| `trust-harbor-client.ps1` | Configure Windows client trust | Yes (Administrator) |

## Accessing Harbor

After successful installation:

1. Navigate to `https://labregistry.local` (or your custom domain)
2. Default credentials:
   - Username: `admin`
   - Password: `Harbor12345`

**Important:** Change the default password immediately after first login.

## Troubleshooting

### Docker login fails with certificate error
Ensure the CA certificate is properly installed on the client machine and Docker has been restarted.

### Cannot reach Harbor web interface
- Verify Harbor containers are running: `docker ps`
- Check `/etc/hosts` contains the correct IP mapping
- Verify firewall allows HTTPS traffic (port 443)

### Harbor containers not starting
Review logs: `docker compose logs` from the Harbor installation directory

## Security Considerations

- This setup uses self-signed certificates suitable for internal/homelab use only
- Change default Harbor admin password immediately
- Certificates generated are valid for 825 days (server) and 10 years (CA)
- CA private key is stored at `~/myCA/private/ca.key.pem` - protect this file

## Additional Resources

- [Harbor Official Documentation](https://goharbor.io/docs/)
- [Harbor GitHub Repository](https://github.com/goharbor/harbor)
- [Docker Documentation](https://docs.docker.com/)

## License

See the LICENSE file in the repository root.