# Terraform Proxmox Learning Example

This directory contains Terraform scripts for provisioning virtual machines on Proxmox VE. **This is a learning example only** and demonstrates how Infrastructure as Code (IaC) can be used to automate VM deployment in a home lab environment.

## ⚠️ Important Notice

- **Educational Purpose**: These scripts are provided for learning and experimentation
- **Anonymized Data**: All sensitive information has been replaced with example values
- **Home Lab Focus**: Designed for home lab environments, not production use
- **Adaptable**: Can be modified for other platforms (ESXi, Azure, Hyper-V, etc.)

## What This Example Does

This Terraform configuration provisions 12 virtual machines across three different Kubernetes distributions:

- 3 VMs for k0s cluster (IDs: 201-203, IPs: 10.0.0.201-203)
- 3 VMs for k3s cluster (IDs: 211-213, IPs: 10.0.0.211-213)
- 3 VMs for Docker Swarm cluster (IDs: 221-223, IPs: 10.0.0.221-223)
- 3 VMs for generic cluster (IDs: 231-233, IPs: 10.0.0.231-233)

Each VM is automatically configured with:

- QEMU Guest Agent for better Proxmox integration
- Avahi daemon for mDNS/Bonjour discovery
- SSH access using provided public keys
- Cloud-init for initial configuration

## Prerequisites

Before using these scripts, ensure you have:

1. **Proxmox Server**: A working Proxmox installation ([Installation Guide](https://pve.proxmox.com/pve-docs/chapter-pve-installation.html))
2. **VM Template**: Ubuntu 24.04 template created in Proxmox ([Cloud-Init Template Guide](https://pve.proxmox.com/wiki/Cloud-Init_Support))
3. **API Token**: Generated in Proxmox for Terraform authentication ([API Token Documentation](https://pve.proxmox.com/pve-docs/pveum.1.html#pveum_tokens))
4. **SSH Keys**: Generated SSH key pair for VM access ([Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement), [Linux/Mac](https://www.ssh.com/academy/ssh/keygen))
5. **Network Configuration**: Proper network setup (bridge, DHCP/static IPs)

## Setup Instructions

1. **Clone and Navigate**:

   ```bash
   git clone <repository>
   cd proxmox/terraform
   ```

2. **Configure Variables**:

   - Copy `secrets.auto.tfvars.example` to `secrets.auto.tfvars`
   - Update `terraform.tfvars` with your environment details
   - Replace all example values with your actual configuration

3. **Update Network Settings**:

   - Modify IP addresses in `main.tf` to match your network
   - Update gateway and DNS server addresses
   - Ensure VM IDs don't conflict with existing VMs

4. **Initialize and Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Files

- `main.tf`: Main VM resource definitions
- `variables.tf`: Variable declarations
- `providers.tf`: Terraform provider configuration
- `terraform.tfvars`: Non-sensitive variable values
- `secrets.auto.tfvars`: Sensitive credentials (excluded from git)

## Security Best Practices

- Never commit `secrets.auto.tfvars` to version control
- Use strong, unique passwords for VM users
- Regularly rotate API tokens
- Consider using Terraform Cloud for state management
- Enable firewall rules appropriate for your environment

## Learning Resources

- [Terraform Proxmox Provider Documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)

## Troubleshooting

Common issues and solutions:

- **Template not found**: Ensure the template name matches exactly
- **Network connectivity**: Verify bridge configuration and IP ranges
- **SSH connection failures**: Check SSH key paths and VM network configuration
- **API authentication**: Verify token ID and secret are correct
