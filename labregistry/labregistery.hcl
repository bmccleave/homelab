packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
  default = "https://192.168.1.184:8006/api2/json"
}

variable "proxmox_username" {
  default = "root@pam"
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "ssh_password" {
  type      = string
  sensitive = true
  description = "SSH password for Ubuntu user during installation"
}

variable "user_password_hash" {
  type      = string
  sensitive = true
  description = "Hashed password for Ubuntu user (generate with: mkpasswd -m sha-512)"
}

source "proxmox-iso" "ubuntu-harbor" {
  api_url      = var.proxmox_api_url
  username     = var.proxmox_username
  password     = var.proxmox_password
  node         = "proxmox-node"           # Change to your Proxmox node name
  vm_name      = "ubuntu-harbor"
  iso_storage  = "local"
  iso_file     = "ubuntu-22.04.4-live-server-amd64.iso" # Upload ISO to Proxmox first
  disk_storage = "local-lvm"
  disk_size    = "20G"
  memory       = 2048
  cores        = 2
  ssh_username = "ubuntu"
  ssh_password = var.ssh_password
  ssh_timeout  = "10m"
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }
  cloud_init = true
  cloud_init_user_data = <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: ${var.user_password_hash}
EOF
}

build {
  sources = ["source.proxmox-iso.ubuntu-harbor"]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y git",
      "git clone https://github.com/YOUR_GITHUB_USER/homelab.git /home/ubuntu/homelab",
      "cd /home/ubuntu/homelab/labregistry",
      "chmod +x install-docker.sh",
      "sudo ./install-docker.sh",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "sleep 30", # Wait for reboot
      "cd /home/ubuntu/homelab/labregistry",
      "chmod +x install-harbor-server.sh",
      "sudo ./install-harbor-server.sh"
    ]
    pause_before = "30s"
  }
}