variable "proxmox_api_url" {
  type = string
  description = "The URL of the Proxmox API"
}

variable "proxmox_api_token_id" {
  type = string
  description = "API Token ID for Proxmox authentication"
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  description = "API Token Secret for Proxmox authentication"
  sensitive = true
}

variable "proxmox_node" {
  type = string
  description = "The name of the Proxmox node"
}

variable "template_name" {
  type = string
  description = "Name of the VM template to clone"
  default = "debian-13-template"
}

variable "vm_user" {
  type = string
  description = "Username for the VM"
  sensitive = true
}

variable "vm_password" {
  type = string
  description = "Password for the VM user"
  sensitive = true
}

variable "ssh_public_key" {
  type = string
  description = "SSH public key for VM access"
}
variable "ssh_public_key2" {
  type = string
  description = "SSH public key for VM access"
}