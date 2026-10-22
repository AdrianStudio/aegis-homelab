data "proxmox_vm" "ubuntu_template90" {
  node_name = "proxmox"
  id        = 9000
}

resource "proxmox_virtual_environment_vm" "test_vm" {
  name      = "tofu-test"
  node_name = "proxmox"
  vm_id     = 100
  cpu {
    type  = "qemu64"
    cores = 2
  }
  disk {
    datastore_id = "local-nvme"
    interface    = "scsi0"
    size         = 20
  }
  memory {
    dedicated = 4096
  }
  scsi_hardware = "virtio-scsi-single"
  clone {
    vm_id = data.proxmox_vm.ubuntu_template90.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.209/24"
        gateway = "192.168.1.1"
      }
    }
    dns {
      servers = ["192.168.1.200"]
    }
    user_account {
      username = "adrian"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }
  agent {
    enabled = false
  }
}
