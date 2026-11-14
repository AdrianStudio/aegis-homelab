# Which OpenTofu and provider versions this code works with.
terraform {
  required_version = ">= 1.8"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.86" # any 0.x from 0.86 up, never 1.0
    }
  }
}
