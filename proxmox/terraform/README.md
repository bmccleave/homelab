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
