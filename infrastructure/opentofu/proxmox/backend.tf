# Where OpenTofu keeps its state: a blob in Azure, accessed with Entra ID (no account keys).
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-lorianx-tfstate"
    storage_account_name = "stlorianxtfstate"
    container_name       = "tfstate"
    key                  = "lorianx.tfstate" # blob name inside the container
    use_azuread_auth     = true              # shared key access is disabled on the account
  }

  # State and plan files are encrypted on the DevBox before they reach Azure.
  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase # from TF_VAR_state_passphrase
    }

    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }

    state {
      method   = method.aes_gcm.main
      enforced = true # refuse to read or write unencrypted state
    }

    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}
