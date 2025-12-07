locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  
  # Windows PowerShell snapshot commands
  snapshot_command_windows = <<-EOT
    # Disable certificate validation for Windows PowerShell 5.1
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $headers = @{
      'Authorization' = 'PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}'
      'Content-Type' = 'application/json'
    }
    
    # Shutdown VM
    Invoke-WebRequest -Uri '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/status/shutdown' -Method POST -Headers $headers -Body '{}' | Out-Null
    Start-Sleep -Seconds 30
    
    # Create snapshot
    $snapBody = @{
      snapname = 'clean'
      description = 'Clean state after initial setup with SSH keys'
    } | ConvertTo-Json
    Invoke-WebRequest -Uri '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/snapshot' -Method POST -Headers $headers -Body $snapBody | Out-Null
    
    # Start VM
    Invoke-WebRequest -Uri '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/status/start' -Method POST -Headers $headers -Body '{}' | Out-Null
  EOT
  
  # Linux/macOS curl snapshot commands
  snapshot_command_unix = <<-EOT
    curl -k -X POST '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/status/shutdown' \
      -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}' \
      -H 'Content-Type: application/json'
    sleep 30
    curl -k -X POST '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/snapshot' \
      -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}' \
      -H 'Content-Type: application/json' \
      -d '{"snapname":"clean","description":"Clean state after initial setup with SSH keys"}'
    curl -k -X POST '${var.proxmox_api_url}/nodes/${var.proxmox_node}/qemu/VMID_PLACEHOLDER/status/start' \
      -H 'Authorization: PVEAPIToken=${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}'
  EOT
}

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
  nameserver    = var.network_dns
  sshkeys = join("\n", var.ssh_public_keys)
  ipconfig0     = "ip=${each.value.ip}/${var.network_cidr},gw=${var.network_gateway}"

  # Wait for cloud-init to complete before running provisioners
  provisioner "remote-exec" {
    inline = var.skip_provisioners ? ["echo 'Provisioners skipped'"] : [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait || true",
      "echo 'Cloud-init completed'"
    ]
    connection {
      type        = "ssh"
      user        = var.vm_user
      host        = each.value.ip
      private_key = file(var.ssh_private_key_path)
      timeout     = "15m"
    }
    on_failure = continue
  }

  # Install QEMU Guest Agent
  provisioner "remote-exec" {
    inline = var.skip_provisioners ? ["echo 'Provisioners skipped'"] : [
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
      private_key = file(var.ssh_private_key_path)
      timeout     = "15m"
    }
    on_failure = continue
  }

  # Install and configure avahi-daemon
  provisioner "remote-exec" {
    inline = var.skip_provisioners ? ["echo 'Provisioners skipped'"] : [
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
      private_key = file(var.ssh_private_key_path)
      timeout     = "15m"
    }
    on_failure = continue
  }

}

# Create "clean" snapshots after VM provisioning
# Only create snapshots when create_snapshots = true to avoid shutting down VMs during initial provisioning
resource "null_resource" "vm_snapshot" {
  for_each = var.create_snapshots ? var.nodes : {}

  depends_on = [proxmox_vm_qemu.k0s_node]

  provisioner "local-exec" {
    command     = replace(local.is_windows ? local.snapshot_command_windows : local.snapshot_command_unix, "VMID_PLACEHOLDER", each.value.vmid)
    interpreter = local.is_windows ? ["powershell.exe", "-Command"] : ["/bin/bash", "-c"]
  }

  triggers = {
    vm_id = proxmox_vm_qemu.k0s_node[each.key].id
    snapshot_requested = var.create_snapshots
  }
}