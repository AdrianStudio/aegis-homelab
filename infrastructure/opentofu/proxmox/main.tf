data "proxmox_vm" "ubuntu_template90" {
  node_name = "proxmox"
  id        = 9000
}

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
    datastore_id = each.value.datastore
    interface    = "scsi0"
    size         = 50
  }
  memory {
    dedicated = each.value.memory
  }
  scsi_hardware = "virtio-scsi-single"
  clone {
    vm_id = each.value.template_id
  }
  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
    dns {
      servers = var.dns_servers
    }
    user_account {
      username = "adrian"
      keys     = [trimspace(file(var.sshkey_path))]
    }
  }
  agent {
    enabled = false
  }
}
