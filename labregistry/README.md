# Harbor Repository Setup Scripts

This directory provides scripts to automate the deployment of a [Harbor](https://goharbor.io/) container registry on Ubuntu.
It includes tools for generating a local Certificate Authority (CA), signing Harbor TLS certificates, and importing the CA certificate on Windows and Linux clients.

## Features

- Automated Harbor installation and configuration
- Local CA creation and certificate signing
- Scripts for client trust setup (Windows and Linux)
- Step-by-step setup instructions

## Usage

1. **Run the setup scripts on your Ubuntu VM:**
   - `avahi-daemon-setup.sh` (optional): Enables hostname resolution. Reboot after running.
   - `install-docker.sh`: Installs Docker and configures the local user for passwordless Docker usage. Reboot after running.
   - `install-harbor-server.sh`: Installs Harbor and generates TLS certificates.
2. **Import the CA certificate on your client machines** using the provided scripts for Windows and Linux.

For more information, see the [Harbor documentation](https://goharbor.io/docs/)