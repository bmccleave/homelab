# Homelab Infrastructure

Automated infrastructure and deployment scripts for a Proxmox-based homelab environment.

## Overview

This repository contains infrastructure-as-code configurations and automation scripts for managing a homelab built on Proxmox VE. The setup includes VM provisioning, container registry deployment, and network service configuration.

**Infrastructure:**
- Intel Xeon NUC running Proxmox VE
- Standard home network behind Orbi router
- Frequent VM creation/destruction for testing and experimentation

## Components

### [Harbor Container Registry](./labregistry/)
Complete Harbor registry deployment with automated TLS certificate management.

**Features:**
- Automated Docker and Harbor installation
- Self-signed CA certificate generation
- Multi-platform client trust configuration (Windows/Linux)
- mDNS hostname resolution support

[View Documentation →](./labregistry/README.md)

### [Proxmox Terraform Configuration](./proxmox/terraform/)
Infrastructure-as-code for automated VM provisioning on Proxmox VE.

**Features:**
- Multi-cluster VM deployment (k0s, k3s, Docker Swarm)
- Cloud-init configuration
- Automated guest agent and mDNS setup
- API token authentication

[View Documentation →](./proxmox/terraform/README.md)

## Shared Utilities

### Scripts

| Script | Description |
|--------|-------------|
| `avahi-daemon-setup.sh` | Configures Avahi daemon for local DNS/mDNS resolution on Ubuntu instances |

### Useful Commands

Convert Windows line endings to Unix format:
```bash
sed -i 's/\r$//' filename.sh
```

## Getting Started

1. **For Container Registry Setup**: Navigate to [`labregistry/`](./labregistry/) and follow the installation guide
2. **For VM Provisioning**: Navigate to [`proxmox/terraform/`](./proxmox/terraform/) and review the prerequisites

## Security Notes

- All example configurations use placeholder values
- Sensitive files are git-ignored (see `.gitignore`)
- Credentials should be stored in `*.auto.tfvars` or `secrets.*` files (excluded from version control)
- This setup is designed for isolated homelab environments, not production use

## Contributing

This is a personal homelab repository. Some scripts were generated with assistance from GitHub Copilot.

## License

See [LICENSE](./LICENSE) file for details.