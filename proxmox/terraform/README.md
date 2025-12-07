# Terraform Proxmox Learning Example

This directory contains Terraform scripts for provisioning virtual machines on Proxmox VE. **This is a learning example only** and demonstrates how Infrastructure as Code (IaC) can be used to automate VM deployment in a home lab environment.

## ⚠️ Important Notice

- **Educational Purpose**: These scripts are provided for learning and experimentation
- **Anonymized Data**: All sensitive information has been replaced with example values
- **Home Lab Focus**: Designed for home lab environments, not production use
- **Adaptable**: Can be modified for other platforms (ESXi, Azure, Hyper-V, etc.)

## What This Example Does

This Terraform configuration provisions 9 virtual machines across three clusters:

- 3 VMs for cl1 cluster (IDs: 201-203, IPs: 10.0.0.201-203)
- 3 VMs for cl2 cluster (IDs: 211-213, IPs: 10.0.0.211-213)
- 3 VMs for cl3 cluster (IDs: 221-223, IPs: 10.0.0.221-223)

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

2. **Copy Example Configuration Files**:

   ```bash
   # Copy the example files to create your local configuration
   cp secrets.auto.tfvars.example secrets.auto.tfvars
   cp nodes.auto.tfvars.example nodes.auto.tfvars
   cp terraform.tfvars.example terraform.tfvars
   ```

   **Important**: The `.example` files are templates tracked in git. Your actual configuration files (`secrets.auto.tfvars`, `nodes.auto.tfvars`, and `terraform.tfvars`) are git-ignored to protect your sensitive data.

3. **Configure Variables**:

   ### `secrets.auto.tfvars` Variables

   | Variable | Description | Example |
   |----------|-------------|---------|
   | `proxmox_api_token_id` | API Token ID from Proxmox (format: user@realm!token-name) | `root@pam!terraform` |
   | `proxmox_api_token_secret` | API Token Secret (UUID format) | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
   | `vm_user` | Username for VM login | `your-vm-username` |
   | `vm_password` | Password for VM user | `your-secure-password` |
   | `ssh_public_keys` | List of SSH public keys for VM access | `["ssh-rsa AAAA...", "ssh-ed25519 AAAA..."]` |
   | `ssh_private_key_path` | Path to SSH private key for provisioner connections | `~/.ssh/id_ed25519` |

   ### `nodes.auto.tfvars` Variables

   | Variable | Description | Example |
   |----------|-------------|---------|
   | `nodes` | Map of VM configurations with VMID and IP address | `{"cl1-node1" = { vmid = 201, ip = "10.0.0.201" }}` |

   ### `terraform.tfvars` Variables

   | Variable | Description | Example |
   |----------|-------------|---------|
   | `proxmox_api_url` | URL of the Proxmox API endpoint | `https://10.0.0.100:8006/api2/json` |
   | `proxmox_node` | Name of the Proxmox node to deploy VMs on | `proxmox1` |
   | `template_name` | Name of the cloud-init template to clone | `ubuntu-24.04-template` |
   | `network_gateway` | Network gateway IP address | `10.0.0.1` |
   | `network_dns` | DNS server IP address | `10.0.0.1` |
   | `network_cidr` | Network CIDR notation (subnet mask) | `24` (for /24) |
   | `skip_provisioners` | Skip SSH provisioners (useful during initial setup) | `true` or `false` |
   | `create_snapshots` | Create clean snapshots after provisioning | `true` or `false` |

   **Configuration Steps**:
   - Edit `secrets.auto.tfvars` with your Proxmox API credentials and SSH keys
   - Edit `nodes.auto.tfvars` with your desired VM configuration (IDs and IP addresses)
   - Update `terraform.tfvars` with your Proxmox server details, template name, and network configuration
   - Replace all example values with your actual configuration

4. **Update Network Settings**:

   - Verify IP addresses in `nodes.auto.tfvars` match your network
   - Update `network_gateway`, `network_dns`, and `network_cidr` in `terraform.tfvars` to match your network
   - Ensure VM IDs don't conflict with existing VMs

5. **Initialize and Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Destroying VMs

To remove all VMs created by Terraform:

### Remove All VMs

```bash
terraform destroy
```

This will show you what will be destroyed and prompt for confirmation.

### Remove All VMs (No Confirmation)

For automation or scripts:

```bash
terraform destroy -auto-approve
```

### Remove Specific VMs

To delete only certain VMs:

```bash
# Delete a single VM
terraform destroy -target=proxmox_vm_qemu.k0s_node[\"cl3-node3\"]

# Delete multiple VMs
terraform destroy -target=proxmox_vm_qemu.k0s_node[\"cl3-node1\"] -target=proxmox_vm_qemu.k0s_node[\"cl3-node2\"]
```

### Remove Snapshots Only

To remove just the snapshots without destroying VMs:

```bash
terraform destroy -target=null_resource.vm_snapshot
```

**Note**: Destroying VMs is permanent and cannot be undone. Always verify the destruction plan before confirming.

## Configuration Files

- `main.tf`: Main VM resource definitions
- `variables.tf`: Variable declarations
- `providers.tf`: Terraform provider configuration
- `terraform.tfvars`: Non-sensitive configuration (git-ignored - copy from `terraform.tfvars.example`)
- `secrets.auto.tfvars`: Sensitive credentials (git-ignored - copy from `secrets.auto.tfvars.example`)
- `nodes.auto.tfvars`: VM node configuration (git-ignored - copy from `nodes.auto.tfvars.example`)

## Security Best Practices

- Never commit `secrets.auto.tfvars`, `terraform.tfvars`, or `nodes.auto.tfvars` to version control
- Always copy from `.example` files and customize with your own values
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
