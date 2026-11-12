variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "vm_username" {
  type        = string
  default     = "adrian"
  description = "Username for the vms"
}

variable "dns_servers" {
  type        = list(string)
  default     = ["192.168.1.200"]
  description = "DNS server/s for the VMs (pihole, google, etc)"
}

variable "gateway" {
  type        = string
  default     = "192.168.1.1"
  description = "Gateway for the VMs"
}

variable "sshkey_path" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  description = "SSH key to add to VMs"
}
