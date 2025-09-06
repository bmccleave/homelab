# k0s Cluster Deployment

This directory contains Infrastructure as Code (IaC) configurations to deploy a highly available 3-node k0s cluster on Proxmox VE.

## Directory Structure

```
k0s/
├── ansible/                    # k0s installation and configuration
│   ├── inventory/             # Inventory configuration
│   ├── group_vars/            # Variable definitions
│   ├── roles/                 # k0s installation role
│   └── site.yml              # Main playbook
└── terraform/                 # Infrastructure provisioning
    ├── main.tf               # VM configurations
    ├── variables.tf          # Variable definitions
    ├── providers.tf          # Proxmox provider config
    ├── outputs.tf            # Output definitions
    ├── terraform.tfvars      # Non-sensitive values
    └── secrets.auto.tfvars   # Sensitive credentials
```

## Prerequisites

- Proxmox VE server with API access
- Terraform (>= 1.0.0)
- Ansible (>= 2.9)
- Ubuntu 24.04 template created using the Packer configuration in `../packer/`
- SSH key pair for VM access

## Part 1: Infrastructure Deployment with Terraform

### Configuration

1. Create `terraform/secrets.auto.tfvars`:
```hcl
proxmox_api_token_id     = "your-token-id"
proxmox_api_token_secret = "your-token-secret"
vm_user                  = "your-username"
vm_password              = "your-secure-password"
```

2. Update `terraform/terraform.tfvars`:
```hcl
proxmox_api_url = "https://your-proxmox:8006/api2/json"
proxmox_node    = "your-node-name"
template_name   = "ubuntu-2404-template"
ssh_public_key  = "your-ssh-public-key"
```

### VM Specifications

Each node is configured identically as a controller+worker node:

- **Names & IDs**:
  - ubuntu-k0s-node1 (VMID: 201)
  - ubuntu-k0s-node2 (VMID: 202)
  - ubuntu-k0s-node3 (VMID: 203)
- **Resources per node**:
  - 4 CPU cores
  - 8GB RAM
  - 64GB disk
  - DHCP networking

### Deployment Steps

1. Initialize Terraform:
```powershell
cd terraform
terraform init
```

2. Review the planned changes:
```powershell
terraform plan
```

3. Apply the configuration:
```powershell
terraform apply
```

## Part 2: k0s Installation with Ansible

### Configuration

1. Update Ansible inventory (`ansible/inventory/hosts.ini`):
```ini
[k0s_controllers]
ubuntu-k0s-node1
ubuntu-k0s-node2
ubuntu-k0s-node3

[k0s:children]
k0s_controllers
```

2. Verify Ansible connectivity:
```powershell
cd ansible
ansible all -i inventory/hosts.ini -m ping
```

### Installation Steps

1. Run the k0s installation playbook:
```powershell
ansible-playbook -i inventory/hosts.ini site.yml
```

This will:
- Install k0s on all nodes
- Configure all nodes as controller+worker nodes
- Set up high availability across all nodes
- Initialize the k0s cluster

## Verification

1. SSH into any controller node:
```bash
ssh your-username@ubuntu-k0s-node1
```

2. Check cluster status:
```bash
sudo k0s kubectl get nodes
```

3. Verify high availability:
```bash
sudo k0s status
```

## Security Notes

- Keep all `secrets.auto.tfvars` files out of version control
- Use strong passwords for VM access
- Secure your Proxmox API tokens
- Use SSH keys for authentication
- Follow k0s security best practices

## Cleanup

To destroy the infrastructure:
```powershell
cd terraform
terraform destroy
```

## Troubleshooting

1. If nodes fail to join the cluster:
   - Verify network connectivity between nodes
   - Check k0s service status: `sudo systemctl status k0scontroller`
   - Review logs: `sudo journalctl -u k0scontroller`

2. For VM deployment issues:
   - Verify Proxmox API access
   - Check template availability
   - Review Terraform logs with `TF_LOG=DEBUG`

## References

- [k0s Documentation](https://docs.k0sproject.io/)
- [Proxmox Terraform Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)