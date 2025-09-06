# Proxmox Homelab Automation

This repository contains scripts and automation resources for managing virtual machines and containers in a Proxmox-based homelab environment. The focus is on Infrastructure as Code (IaC) practices, leveraging tools such as Packer, Ansible, and Terraform to streamline the provisioning and configuration of Ubuntu 24.04 VMs and containerized workloads.

## Features

- **Automated VM Image Creation:**
  Use [Packer](https://www.packer.io/) to build custom Ubuntu 24.04 images tailored for Proxmox deployments.
- **Configuration Management:**
  Scripts and templates for configuring essential services (e.g., Avahi Daemon) and initial VM setup.
- **Infrastructure as Code:**
  Terraform configurations for automating VM provisioning and k0s cluster setup.
- **Container Orchestration:**
  Resources for deploying k0s Kubernetes clusters and other container technologies.

## Directory Structure

```
proxmox/
├── packer/                 # Packer templates and build scripts
├── ubuntu-24.04/          # Ubuntu 24.04 specific configurations
│   ├── packer/            # Ubuntu 24.04 Packer templates
│   └── k0s/               # k0s cluster deployment
│       └── terraform/     # Terraform configs for k0s nodes
└── http/                  # Cloud-init and provisioning scripts
```

## Getting Started

### 1. Build Ubuntu 24.04 Template
```bash
cd proxmox/ubuntu-24.04/packer
./build.sh
```

### 2. Deploy k0s Cluster Nodes

#### Prerequisites
- Terraform installed
- Proxmox API token configured
- Ubuntu 24.04 template created via Packer

#### Setup Steps
1. **Configure Terraform Variables:**
   ```bash
   cd proxmox/ubuntu-24.04/k0s/terraform
   ```

2. **Create `secrets.auto.tfvars` with sensitive data:**
   ```hcl
   proxmox_api_token_id     = "your-token-id"
   proxmox_api_token_secret = "your-token-secret"
   vm_user                  = "your-username"
   vm_password              = "your-secure-password"
   ```

3. **Update `terraform.tfvars` with your environment details:**
   ```hcl
   proxmox_api_url = "https://your-proxmox:8006/api2/json"
   proxmox_node    = "your-node-name"
   template_name   = "ubuntu-2404-template"
   ssh_public_key  = "your-ssh-public-key"
   ```

4. **Initialize and Apply Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

This will create three VMs:
- ubuntu-k0s-node1 (VMID: 201)
- ubuntu-k0s-node2 (VMID: 202)
- ubuntu-k0s-node3 (VMID: 203)

Each node is configured with:
- 2 CPU cores
- 4GB RAM
- 32GB disk
- DHCP networking
- Cloud-init with custom user credentials

## Security Notes

- Keep `secrets.auto.tfvars` out of version control
- Use SSH keys for authentication when possible
- Store API tokens securely

## References

- [Packer Template Reference](https://github.com/samgabrail/ubuntu24-04-vms)
- [k0s Documentation](https://docs.k0sproject.io/)
- [Proxmox Terraform Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)

---

For questions or contributions, please open an issue or submit a pull request.
