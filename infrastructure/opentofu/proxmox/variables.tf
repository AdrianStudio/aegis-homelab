# Inputs. The description of each one is the documentation (shown in README).

variable "proxmox_api_token" {
  description = "Proxmox API token: 'opentofu@pve!opentofu=<secret>'. Set via TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true # hidden in plan output
}

variable "state_passphrase" {
  description = "Passphrase for OpenTofu state encryption. Set via TF_VAR_state_passphrase."
  type        = string
  sensitive   = true # hidden in plan output
}

# Shared by all VMs.

variable "vm_username" {
  description = "Linux user created in each VM by Cloud-Init"
  type        = string
  default     = "adrian"
}

variable "dns_servers" {
  description = "DNS servers for the VMs (Pi-hole)"
  type        = list(string)
  default     = ["192.168.1.200"]
}

variable "gateway" {
  description = "Default gateway for the VMs"
  type        = string
  default     = "192.168.1.1"
}

variable "sshkey_path" {
  description = "Path to the public SSH key installed in each VM"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

# Per VM: one entry = one VM. Add a row to add a VM.

variable "k3s_nodes" {
  description = "K3s VMs, keyed by VM name"
  type = map(object({
    node_name   = string # Proxmox node to run on
    vm_id       = number
    ip          = string # CIDR, e.g. 192.168.1.31/24
    cores       = number
    memory      = number # MiB
    datastore   = string # must exist on node_name
    template_id = number # template on the same node
  }))
  default = {
    "k3s-01" = { node_name = "proxmox", vm_id = 301, ip = "192.168.1.31/24", cores = 4, memory = 6144, datastore = "local-nvme", template_id = 9000 }
    "k3s-02" = { node_name = "pve-worker1", vm_id = 302, ip = "192.168.1.32/24", cores = 4, memory = 8192, datastore = "local-lvm", template_id = 9001 }
    "k3s-03" = { node_name = "pve-worker2", vm_id = 303, ip = "192.168.1.33/24", cores = 4, memory = 8192, datastore = "local-lvm", template_id = 9002 }
  }
}
