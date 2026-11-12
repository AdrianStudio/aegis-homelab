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

variable "k3s_nodes" {
  description = "K3s VMs: one entry per VM, keyed by VM name"
  type = map(object({
    node_name   = string
    vm_id       = number
    ip          = string
    cores       = number
    memory      = number
    datastore   = string
    template_id = number
  }))
  default = {
    "k3s-01" = { node_name = "proxmox", vm_id = 301, ip = "192.168.1.31/24", cores = 4, memory = 6144, datastore = "local-nvme", template_id = 9000 }
    "k3s-02" = { node_name = "pve-worker1", vm_id = 302, ip = "192.168.1.32/24", cores = 4, memory = 8192, datastore = "local-lvm", template_id = 9001 }
    "k3s-03" = { node_name = "pve-worker2", vm_id = 303, ip = "192.168.1.33/24", cores = 4, memory = 8192, datastore = "local-lvm", template_id = 9002 }
  }
}
