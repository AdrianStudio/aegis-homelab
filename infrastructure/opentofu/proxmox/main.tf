# Read-only lookup of template 9000 (data = read, resource = create/manage).
# Nothing is changed in Proxmox. Only outputs.tf uses it now, as a quick
# "can we reach Proxmox and see the template?" check on every plan.
data "proxmox_vm" "ubuntu_template90" {
  node_name = "proxmox"
  id        = 9000
}

# The three K3s VMs, built from one block.
resource "proxmox_virtual_environment_vm" "k3s" {
  # One VM per entry in var.k3s_nodes (variables.tf).
  # each.key = the entry's name ("k3s-01"), each.value = its columns.
  # Each copy's address in state is k3s["k3s-01"], k3s["k3s-02"], ...
  for_each  = var.k3s_nodes
  name      = each.key
  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  # Per-VM values come from the table. Values written directly below are
  # the same for every VM, so they live here once instead of in the table.

  cpu {
    # qemu64 is a generic, slow-ish CPU model. Fine for now; "host" would expose
    # the real CPU features but would block live migration between nodes.
    type  = "qemu64"
    cores = each.value.cores
  }

  disk {
    # Each node only has local storage, so each VM's disk must live on a
    # datastore that exists on its own node (local-nvme or local-lvm).
    datastore_id = each.value.datastore
    interface    = "scsi0"
    # GB. Room for container images and etcd. Disks can grow, never shrink.
    size = 50
  }

  memory {
    # In MiB: 6144 = 6 GB, 8192 = 8 GB.
    dedicated = each.value.memory
  }

  # Match the template's controller. Without this the provider default
  # (virtio-scsi-pci) would be used.
  scsi_hardware = "virtio-scsi-single"

  clone {
    # Each node clones its own local template (9000/9001/9002), because
    # templates on local storage can't be cloned to another node.
    vm_id = each.value.template_id
  }

  # Cloud-Init: applied by the VM on first boot.
  initialization {
    ip_config {
      ipv4 {
        # Static IP in CIDR form (/24). Must be outside the router's DHCP range,
        # or another device can take it (this happened with .213).
        address = each.value.ip
        gateway = var.gateway
      }
    }

    dns {
      # Already a list in variables.tf, so no extra [ ] here.
      servers = var.dns_servers
    }

    # The Linux user created inside the VM, used for SSH and Ansible.
    # Not the same as opentofu@pve, which is the Proxmox API user.
    user_account {
      username = "adrian"
      # The DevBox's public key. trimspace() strips the trailing newline in
      # the .pub file; without it Proxmox stores the key differently and
      # every plan shows a change that never goes away.
      keys = [trimspace(file(var.sshkey_path))]
    }
  }

  # The Ubuntu cloud image doesn't include qemu-guest-agent, so the provider
  # would wait for an agent that never answers (and needs VM.GuestAgent.Audit).
  # Turn on after Ansible installs the agent.
  agent {
    enabled = false
  }
}
