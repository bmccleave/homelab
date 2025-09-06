resource "proxmox_vm_qemu" "ubuntu_server" {
  name        = var.vm_name
  target_node = var.proxmox_node
  clone       = "ubuntu-cloudinit-template" // Name of your cloud-init template in Proxmox
  cores       = var.vm_cores
  memory      = var.vm_memory
  sockets     = 1

  disk {
    size    = var.vm_disk_size
    type    = "scsi"
    storage = var.storage
  }

  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }

  ipconfig0 = "ip=dhcp"

  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  os_type = "cloud-init"
}