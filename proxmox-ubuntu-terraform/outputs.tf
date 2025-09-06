output "vm_id" {
  value = proxmox_vm_qemu.ubuntu_server.id
}

output "vm_name" {
  value = proxmox_vm_qemu.ubuntu_server.name
}

output "vm_ip" {
  value = proxmox_vm_qemu.ubuntu_server.network[0].ip
}