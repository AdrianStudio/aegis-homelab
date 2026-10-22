output "template_name" {
  value       = data.proxmox_vm.ubuntu_template90.name
  description = "Name of the template VM read from Proxmox."
}

output "is_template" {
  value       = data.proxmox_vm.ubuntu_template90.template
  description = "Whether the VM is a Proxmox template (master copy for cloning)."
}
