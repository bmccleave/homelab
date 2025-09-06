packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

##################################################################################
# VARIABLES
##################################################################################

# Connection Variables
variable "proxmox_url" {
  type        = string
  description = "The Proxmox API URL"
  default     = "https://192.168.1.95:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "The Proxmox username for API operations"
  default     = "root@pam!terraform"
}

variable "proxmox_token" {
  type        = string
  description = "The Proxmox API token"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to build on"
  default     = "proxmox"
}

# VM Identification
variable "vm_id" {
  type        = string
  description = "The ID for the VM template"
  default     = "9000"
}

# VM ISO Settings
variable "iso_file" {
  type        = string
  description = "The ISO file to use for installation"
  default     = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:45f9ddf5b54cb51a0badcd27d633e587e6f176762d7cda49862095d92dfd2055"
}

# VM Credentials
variable "ssh_username" {
  type        = string
  description = "The username to use for SSH"
  default     = "ubuntu"
}

variable "ssh_password" {
  type        = string
  description = "The password to use for SSH"
  sensitive   = true
  default     = "ubuntu"
}

##################################################################################
# LOCALS
##################################################################################

locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

##################################################################################
# SOURCE
##################################################################################

source "proxmox-iso" "ubuntu-2404" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM General Settings
  vm_id                = var.vm_id
  vm_name              = "ubuntu-2404-template"
  template_description = "Ubuntu 24.04 Server Template, built with Packer on ${local.buildtime}"

  # VM ISO Settings

  boot_iso {
    type              = "ide"
    iso_file          = var.iso_file
    unmount           = true
    keep_cdrom_device = false
    iso_checksum      = var.iso_checksum
  }

  # Explicitly set boot order to prefer scsi0 (installed disk) over ide devices
  boot = "order=scsi0;net0;ide0"

  # VM System Settings
  qemu_agent = true
  cores      = "2"
  memory     = "2048"

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
    ssd          = true
  }

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Cloud-init config via additional ISO
  additional_iso_files {
    type              = "ide"
    index             = 1
    iso_storage_pool  = "local"
    unmount           = true
    keep_cdrom_device = false
    cd_files = [
      "./http/meta-data",
      "./http/user-data"
    ]
    cd_label = "cidata"
  }

  # PACKER Boot Commands
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall quiet ds=nocloud",
    "<f10><wait>",
    "<wait1m>",
    "yes<enter>"
  ]

  # Communicator Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
}

##################################################################################
# BUILD
##################################################################################

build {
  name    = "ubuntu-2404"
  sources = ["source.proxmox-iso.ubuntu-2404"]

  # Provisioning the VM Template
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",

      # Install and configure avahi-daemon
      "echo 'Installing avahi-daemon...'",
      "sudo apt-get update",
      "sudo apt-get install -y avahi-daemon",

      # Configure avahi-daemon
      "echo 'Configuring avahi-daemon...'",
      "CONF_FILE='/etc/avahi/avahi-daemon.conf'",
      "sudo cp \"$CONF_FILE\" \"$CONF_FILE.bak.$(date +%s)\"",

      # Set configuration values
      "sudo sed -i 's/^[#;]\\?\\s*use-ipv6\\s*=.*/use-ipv6=no/' \"$CONF_FILE\"",
      "sudo sed -i 's/^[#;]\\?\\s*publish-resolv-conf-dns-servers\\s*=.*/publish-resolv-conf-dns-servers=yes/' \"$CONF_FILE\"",
      "sudo sed -i 's/^[#;]\\?\\s*publish-aaaa-on-ipv4\\s*=.*/publish-aaaa-on-ipv4=no/' \"$CONF_FILE\"",

      # Restart and enable avahi-daemon
      "echo 'Restarting avahi-daemon...'",
      "sudo systemctl restart avahi-daemon",
      "sudo systemctl enable avahi-daemon",

      # Cleanup and template preparation
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "echo 'Ubuntu 24.04 Template by Packer - Creation Date: $(date)' | sudo tee /etc/issue"
    ]
  }

  # Added provisioner to forcibly eject ISO and prepare for reboot
  provisioner "shell" {
    inline = [
      "echo 'Completed installation. Preparing for template conversion...'",
      "echo 'Ejecting CD-ROM devices...'",
      "sudo eject /dev/sr0 || true",
      "sudo eject /dev/sr1 || true",
      "echo 'Removing CD-ROM entries from fstab if present...'",
      "sudo sed -i '/cdrom/d' /etc/fstab",
      "sudo sync",
      "echo 'Setting disk as boot device...'",
      "sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub",
      "sudo update-grub",
      "echo 'Clearing cloud-init status to ensure fresh start on first boot...'",
      "sudo cloud-init clean --logs",
      "echo 'Installation and cleanup completed successfully!'"
    ]
    expect_disconnect = true
  }
}
