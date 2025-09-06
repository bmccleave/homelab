variable "proxmox_server" {
  description = "The address of the Proxmox server"
  type        = string
}

variable "proxmox_user" {
  description = "The username for Proxmox authentication"
  type        = string
}

variable "proxmox_password" {
  description = "The password for Proxmox authentication"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "ubuntu-2404"
}

variable "vm_memory" {
  description = "The amount of memory for the VM in MB"
  type        = number
  default     = 2048
}

variable "vm_cpu" {
  description = "The number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "The size of the VM disk in GB"
  type        = number
  default     = 32
}

variable "vm_network_bridge" {
  description = "The network bridge to use for the VM"
  type        = string
  default     = "vmbr0"
}

variable "ssh_user" {
  description = "The initial user to create on the VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_password" {
  description = "The password for the initial user"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "The Proxmox node to deploy the VM on"
  type        = string
}


variable "vm_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "storage" {
  description = "The Proxmox storage to use for the VM disk"
  type        = string
  default     = "local-lvm"
}