# Reads template 9000 (read-only). Only used by outputs.tf.
data "proxmox_vm" "ubuntu_template90" {
  node_name = "proxmox"
  id        = 9000
}

# The 3 K3s VMs, one per entry in var.k3s_nodes.
resource "proxmox_virtual_environment_vm" "k3s" {
  for_each  = var.k3s_nodes
  name      = each.key
  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  cpu {
    type  = "qemu64"
    cores = each.value.cores
  }

  disk {
    datastore_id = each.value.datastore # must exist on the VM's own node
    interface    = "scsi0"
    size         = 50 # GB, can grow but never shrink
  }

  memory {
    dedicated = each.value.memory # MiB
  }

  scsi_hardware = "virtio-scsi-single" # same as the template

  clone {
    vm_id = each.value.template_id # each node clones its own template
  }

  # Cloud-Init, applied on first boot.
  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip # keep outside the router's DHCP range
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    # Linux user inside the VM (not opentofu@pve).
    user_account {
      username = var.vm_username
      keys     = [trimspace(file(var.sshkey_path))] # trimspace stops a never-ending diff
    }
  }

  #Lets Proxmox see the VM's IP and shut it down cleanly; needs qemu-guest-agent (installed by Ansible).
  agent {
    enabled = true
  }
}
