# OpenTofu: Proxmox VMs

Creates the three K3s VMs on the Proxmox cluster by cloning the Ubuntu 24.04 Cloud-Init templates.

| VM | Node | VM ID | IP | CPU / RAM | Disk |
|---|---|---|---|---|---|
| `k3s-01` | `proxmox` | 301 | 192.168.1.31 | 4 / 6 GB | 50 GB `local-nvme` |
| `k3s-02` | `pve-worker1` | 302 | 192.168.1.32 | 4 / 8 GB | 50 GB `local-lvm` |
| `k3s-03` | `pve-worker2` | 303 | 192.168.1.33 | 4 / 8 GB | 50 GB `local-lvm` |

Each VM gets a static IP, Pi-hole DNS, and the user `adrian` with the DevBox's SSH key, all through Cloud-Init.

## Prerequisites

- Templates `9000` (`proxmox`), `9001` (`pve-worker1`), `9002` (`pve-worker2`) exist.
- Proxmox API user `opentofu@pve` with token `opentofu` and the `OpenTofuVMManager` role on `/vms`, `/storage` and `/sdn/zones`.
- The token is exported in the shell, never written to a file in the repo:

  ```bash
  export TF_VAR_proxmox_api_token='opentofu@pve!opentofu=<secret>'
  ```

## Usage

```bash
tofu init      # once, downloads the provider
tofu plan      # review changes
tofu apply     # create or update the VMs
```

To override defaults, copy `terraform.tfvars.example` to `terraform.tfvars` (gitignored).

After rebuilding a VM, clear its old SSH host key: `ssh-keygen -R 192.168.1.31`.

## Notes

- **State** (`terraform.tfstate`) is local on the DevBox and gitignored. Losing it means OpenTofu forgets the VMs.
- **Guest agent** is disabled until Ansible installs `qemu-guest-agent` in the VMs.
- Design decisions: [ADR 0001](../../../docs/decisions/0001-k3s-vm-layout.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.86 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers for the VMs (Pi-hole) | `list(string)` | <pre>[<br/>  "192.168.1.200"<br/>]</pre> | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | Default gateway for the VMs | `string` | `"192.168.1.1"` | no |
| <a name="input_k3s_nodes"></a> [k3s\_nodes](#input\_k3s\_nodes) | K3s VMs, keyed by VM name | `map(object)` | see `variables.tf` | no |
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token: 'opentofu@pve!opentofu=<secret>'. Set via TF\_VAR\_proxmox\_api\_token. | `string` | n/a | yes |
| <a name="input_sshkey_path"></a> [sshkey\_path](#input\_sshkey\_path) | Path to the public SSH key installed in each VM | `string` | `"~/.ssh/id_ed25519.pub"` | no |
| <a name="input_vm_username"></a> [vm\_username](#input\_vm\_username) | Linux user created in each VM by Cloud-Init | `string` | `"adrian"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_template"></a> [is\_template](#output\_is\_template) | True if VM 9000 is a template |
| <a name="output_template_name"></a> [template\_name](#output\_template\_name) | Name of template 9000 |
<!-- END_TF_DOCS -->
