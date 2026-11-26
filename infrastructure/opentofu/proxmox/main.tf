locals {
  # Image Factory URL: Talos version + schematic (nocloud, qemu-guest-agent).
  # qcow2 because Proxmox only decompresses ISO downloads, and "import" needs an uncompressed disk image.
  talos_image_url = "https://factory.talos.dev/image/${var.talos_schematic_id}/${var.talos_version}/nocloud-amd64.qcow2"
}

# Talos disk image, downloaded once to each Proxmox node that runs a Talos VM.
resource "proxmox_download_file" "talos_image" {
  for_each     = toset([for n in var.talos_nodes : n.node_name])
  node_name    = each.key
  content_type = "import" # VMs import it through the API, no SSH to the host needed
  datastore_id = "local"  # directory storage with the "Import" content type
  url          = local.talos_image_url
  file_name    = "talos-${var.talos_version}-${substr(var.talos_schematic_id, 0, 8)}-nocloud-amd64.qcow2"
}

# The 3 Talos VMs, one per entry in var.talos_nodes.
resource "proxmox_virtual_environment_vm" "talos" {
  for_each        = var.talos_nodes
  name            = each.key
  node_name       = each.value.node_name
  vm_id           = each.value.vm_id
  tags            = ["lorianx", "talos"]
  stop_on_destroy = true # force stop if a clean shutdown does not finish

  cpu {
    type  = "host" # Talos needs x86-64-v2; qemu64 does not provide it
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory # MiB
  }

  scsi_hardware = "virtio-scsi-single"

  # Boot disk imported from the downloaded Talos image (converted to raw on the target storage).
  disk {
    datastore_id = each.value.datastore                                       # must exist on the VM's own node
    import_from  = proxmox_download_file.talos_image[each.value.node_name].id # was file_id (needs SSH)
    interface    = "scsi0"
    file_format  = "raw"
    size         = 50 # GB, can grow but never shrink
    discard      = "on"
    iothread     = true
    ssd          = true
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26" # Linux kernel 2.6+
  }

  # Read by Talos (nocloud platform) on boot: static IP, gateway and DNS.
  initialization {
    datastore_id = each.value.datastore
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24" # outside the router's DHCP range
        gateway = var.gateway
      }
    }
    dns {
      servers = var.dns_servers
    }
  }

  # Lets Proxmox see the VM's IP and shut it down cleanly (qemu-guest-agent extension in the image).
  agent {
    enabled = true
  }
}
