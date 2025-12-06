resource "proxmox_vm_qemu" "k0s_node" {
  for_each = var.nodes

  name        = each.key
  target_node = var.proxmox_node
  vmid        = each.value.vmid
  clone       = var.template_name

  # VM Settings - Increased resources for controller+worker nodes
  cpu {
    cores = 2
    type  = "host"
  }
  memory   = 4096
  scsihw   = "virtio-scsi-pci"

  disk {
    type    = "disk"
    storage = "local-lvm"
    size    = "32G"
    slot    = "scsi0"
  }

  disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = "local-lvm"
    size    = "4M"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
    id     = 0
  }

  # VM Settings
  agent      = 0  # Disable agent check temporarily
  os_type    = "cloud-init"
  boot       = "order=scsi0;net0"

  # Cloud-Init Settings
  ciuser        = var.vm_user
  cipassword    = var.vm_password
  searchdomain  = "local"
  nameserver    = "192.168.1.1"  # Update this to your router/DNS server IP
  sshkeys = join("\n", var.ssh_public_keys)
  ipconfig0     = "ip=${each.value.ip}/24,gw=192.168.1.1"  # Update gateway to match your network

  # Install QEMU Guest Agent
  provisioner "remote-exec" {
    inline = [
      "echo 'Installing QEMU Guest Agent...'",
      "sudo apt-get update",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
    connection {
      type        = "ssh"
      user        = var.vm_user
      host        = each.value.ip
      private_key = file("~/.ssh/id_rsa")  # Update this path to your private key
      timeout     = "5m"
    }
    on_failure = continue
  }

  # Install and configure avahi-daemon
  provisioner "remote-exec" {
    inline = [
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
    ]
    connection {
      type        = "ssh"
      user        = var.vm_user
      host        = each.value.ip
      private_key = file("~/.ssh/id_rsa")  # Update this path to your private key
      timeout     = "5m"
    }
  }

}

# Create "clean" snapshots after VM provisioning
resource "null_resource" "vm_snapshot" {
  for_each = var.nodes

  depends_on = [proxmox_vm_qemu.k0s_node]

  provisioner "local-exec" {
    command = "curl -k -X POST '${var.proxmox_api_url}/api2/json/nodes/${var.proxmox_node}/qemu/${each.value.vmid}/status/shutdown' -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}' -H 'Content-Type: application/json'; Start-Sleep -Seconds 30; curl -k -X POST '${var.proxmox_api_url}/api2/json/nodes/${var.proxmox_node}/qemu/${each.value.vmid}/snapshot' -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}' -H 'Content-Type: application/json' -d '{\"snapname\":\"clean\",\"description\":\"Clean state after initial setup with SSH keys\"}'; curl -k -X POST '${var.proxmox_api_url}/api2/json/nodes/${var.proxmox_node}/qemu/${each.value.vmid}/status/start' -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}'"
    interpreter = ["pwsh", "-Command"]
  }

  triggers = {
    vm_id = proxmox_vm_qemu.k0s_node[each.key].id
  }
}