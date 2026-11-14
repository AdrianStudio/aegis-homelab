# Values printed after plan/apply. Quick check that Proxmox and template 9000 are reachable.

output "template_name" {
  description = "Name of template 9000"
  value       = data.proxmox_vm.ubuntu_template90.name
}

output "is_template" {
  description = "True if VM 9000 is a template"
  value       = data.proxmox_vm.ubuntu_template90.template
}
