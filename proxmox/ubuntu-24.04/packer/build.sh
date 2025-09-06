#!/bin/bash
# =====================================================================================
# PACKER BUILD SCRIPT FOR UBUNTU 24.04 PROXMOX TEMPLATE
# =====================================================================================
# This script automates the Packer build process for creating a Ubuntu 24.04 template
# on Proxmox VE. It handles initialization, variable loading, and build execution.

# Navigate to the directory containing this script
# This ensures the script works regardless of where it's called from
cd "$(dirname "$0")"

# Check if Packer is installed
# Verifies that the 'packer' command is available in the system PATH
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install it from https://www.packer.io/downloads"
    exit 1
fi

# Check if secrets file exists
# The secrets file contains sensitive information like API tokens and passwords
if [ ! -f "secrets.pkrvars.hcl" ]; then
    echo "Creating example secrets file..."
    cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
    echo "Please edit secrets.pkrvars.hcl with your actual credentials before running this script again."
    exit 1
fi

# Initialize Packer plugins
# This downloads and installs the required Packer plugins defined in the .pkr.hcl file
echo "Initializing Packer plugins..."
packer init ubuntu-2404.pkr.hcl

# Run Packer build with both variable files
# -force: Overwrites any existing output artifacts
# -on-error=ask: Prompts for user input if an error occurs during the build
echo "Starting Packer build..."
packer build -force -on-error=ask \
  -var-file=variables.pkrvars.hcl \
  -var-file=secrets.pkrvars.hcl \
  ubuntu-2404.pkr.hcl

echo "Build process completed!" 