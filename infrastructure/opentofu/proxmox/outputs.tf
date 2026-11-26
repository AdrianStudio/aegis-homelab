# Values available after apply. Credentials are sensitive: read them with `tofu output -raw <name>`.

output "talosconfig" {
  description = "talosctl client configuration (write it to ~/.talos/config)"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Admin kubeconfig through the API VIP (write it to ~/.kube/config)"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "node_ips" {
  description = "Talos node IPs by hostname"
  value       = { for k, n in var.talos_nodes : k => n.ip }
}
