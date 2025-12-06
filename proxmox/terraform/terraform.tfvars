proxmox_api_url = "https://192.168.1.184:8006/api2/json"
proxmox_node = "proxmox2"
template_name = "ubuntu-24.04-template"

# Set to true to skip provisioners (useful for initial VM creation or troubleshooting)
# After VMs are created and network is working, set to false to run provisioners
skip_provisioners = true

# Set to true only after VMs are fully configured to create clean snapshots
# WARNING: This will shut down VMs to take snapshots, then restart them
create_snapshots = true