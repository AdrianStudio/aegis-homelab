# How OpenTofu connects to the Proxmox API.
provider "proxmox" {
  endpoint  = "https://192.168.1.100:8006/"
  insecure  = true                  # self-signed cert, lab only
  api_token = var.proxmox_api_token # from TF_VAR_proxmox_api_token
}
