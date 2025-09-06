# k0s Ansible Deployment

This Ansible configuration installs and configures a k0s Kubernetes cluster on the VMs created by Terraform.

## Prerequisites

- Ansible installed on your control machine
- SSH access to all nodes
- Python installed on all nodes

## Usage

1. Update the inventory file with your node information:
   ```bash
   vim inventory/hosts.ini
   ```

2. Run the playbook:
   ```bash
   ansible-playbook -i inventory/hosts.ini site.yml
   ```

## Configuration

- Edit `group_vars/all.yml` to change k0s version or paths
- Modify the roles/k0s/tasks/main.yml to customize the installation process

## Verification

After running the playbook, SSH into the controller node and run:
```bash
sudo k0s kubectl get nodes
```

You should see all three nodes in your cluster.