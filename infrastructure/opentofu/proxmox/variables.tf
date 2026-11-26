# Inputs. The description of each one is the documentation (shown in README).

variable "proxmox_api_token" {
  description = "Proxmox API token: 'opentofu@pve!tofu-2611=<secret>'. Set via TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true # hidden in plan output
}

variable "state_passphrase" {
  description = "Passphrase for OpenTofu state encryption. Set via TF_VAR_state_passphrase."
  type        = string
  sensitive   = true # hidden in plan output
}

# Cluster-wide settings.

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "lorianx"
}

variable "cluster_vip" {
  description = "Floating IP for the Kubernetes API, held by one control plane at a time"
  type        = string
  default     = "192.168.1.40"
}

variable "talos_version" {
  description = "Talos Linux version for the image and the machine configuration"
  type        = string
  default     = "v1.14.7"
}

variable "talos_schematic_id" {
  description = "Image Factory schematic: nocloud platform + siderolabs/qemu-guest-agent"
  type        = string
  default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "dns_servers" {
  description = "DNS servers for the nodes (Pi-hole)"
  type        = list(string)
  default     = ["192.168.1.200"]
}

variable "gateway" {
  description = "Default gateway for the nodes"
  type        = string
  default     = "192.168.1.1"
}

# Per node: one entry = one Talos VM (control plane that also runs workloads).

variable "talos_nodes" {
  description = "Talos VMs, keyed by hostname"
  type = map(object({
    node_name = string # Proxmox node to run on
    vm_id     = number
    ip        = string # plain IPv4, outside the router's DHCP range (.128-.254)
    cores     = number
    memory    = number # MiB
    datastore = string # must exist on node_name
  }))
  default = {
    "talos-01" = { node_name = "proxmox", vm_id = 401, ip = "192.168.1.41", cores = 4, memory = 6144, datastore = "local-nvme" }
    "talos-02" = { node_name = "pve-worker1", vm_id = 402, ip = "192.168.1.42", cores = 4, memory = 8192, datastore = "local-lvm" }
    "talos-03" = { node_name = "pve-worker2", vm_id = 403, ip = "192.168.1.43", cores = 4, memory = 8192, datastore = "local-lvm" }
  }
}
