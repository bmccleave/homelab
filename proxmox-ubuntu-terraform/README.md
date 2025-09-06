# Proxmox Ubuntu Terraform

This project provides a Terraform configuration to provision a minimal Ubuntu 24.04 server on a local Proxmox server. The setup includes the installation of essential packages such as OpenSSH, avahi-daemon, net-tools, and ping, along with an initial user setup that has passwordless sudo access.

## Project Structure

The project consists of the following files:

- **main.tf**: Contains the main Terraform configuration for provisioning the Ubuntu server, including VM specifications and user data scripts.
- **variables.tf**: Defines input variables for the Terraform configuration, such as Proxmox server details and VM specifications.
- **outputs.tf**: Specifies the outputs of the Terraform configuration, including the IP address of the newly created VM.
- **providers.tf**: Configures the Terraform provider for Proxmox, including authentication and connection settings.
- **scripts/init.sh**: A shell script executed during VM initialization to install necessary packages and set up the initial user.

## Prerequisites

- A running Proxmox server with access to the API.
- Terraform installed on your local machine.
- Proper permissions to create VMs on the Proxmox server.

## Setup Instructions

1. Clone this repository to your local machine.
2. Navigate to the project directory:
   ```bash
   cd proxmox-ubuntu-terraform
   ```
3. **Configure your Proxmox server details and VM specifications:**

   It is recommended **not to store sensitive information such as passwords or API tokens directly in `variables.tf`**, as this file is typically checked into version control. For a simple home setup, you can securely provide secrets using one of the following methods:

   - **Environment Variables:** Set environment variables before running Terraform. For example:
    ```bash
    export TF_VAR_proxmox_api_token="your-proxmox-api-token"
    export TF_VAR_ssh_password="your-vm-password"
    ```
   - **Terraform Variable Files:** Create a separate file (e.g., `secrets.auto.tfvars`) and add it to `.gitignore` to prevent it from being committed:
    ```hcl
    proxmox_api_token = "your-proxmox-api-token"
    ssh_password      = "your-vm-password"
    ```
   - **Terraform CLI Prompts:** If a variable is not set, Terraform will prompt you to enter it securely at runtime.

   Choose the method that best fits your workflow and security needs. **Never commit secrets to version control.**
4. **To configure the VM's username, password, VM name, and hostname:**
   - Open `variables.tf` in your editor.
   - Set the following variables as desired:
     - `ssh_user` – the initial username for the VM.
     - `ssh_password` – the password for the initial user.
     - `vm_name` – the name of the VM as it will appear in Proxmox.
   - The VM's hostname will be set to the value of `vm_name` by default. If you wish to use a different hostname, update the relevant section in `main.tf` or the `init.sh` script accordingly.
5. Initialize Terraform:
   ```bash
   terraform init
   ```
6. Plan the deployment:
   ```bash
   terraform plan
   ```
7. Apply the configuration to create the VM:
   ```bash
   terraform apply
   ```
8. After the provisioning is complete, you can access the VM using SSH.

## Notes

- Ensure that the Proxmox server is accessible from the machine where you are running Terraform.
- Modify the `scripts/init.sh` file if you need to install