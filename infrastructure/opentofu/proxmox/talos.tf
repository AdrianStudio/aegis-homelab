# Talos cluster: secrets, machine configuration, apply, bootstrap and credentials.

locals {
  cluster_endpoint = "https://${var.cluster_vip}:6443" # Kubernetes API through the VIP
  bootstrap_node   = var.talos_nodes["talos-01"].ip    # etcd is initialised on one node only
  node_ips         = [for n in var.talos_nodes : n.ip]
}

# Cluster CA keys and tokens. Generated once; they live only in the encrypted state.
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# Control plane configuration shared by the 3 nodes (all of them also run workloads).
# Talos 1.14 uses one document per topic; each patch below adds, changes or deletes one document.
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version

  config_patches = [
    # Installer for future upgrades: same schematic, so qemu-guest-agent is kept.
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UnattendedInstallConfig"
      installer = {
        image = "factory.talos.dev/nocloud-installer/${var.talos_schematic_id}:${var.talos_version}"
      }
      provisioning = {
        diskSelector = { match = "disk.dev_path == \"/dev/sda\"" } # the VM's only disk (checked with: talosctl get disks)
      }
    }),
    # Kubernetes API VIP, held by one control plane at a time.
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "Layer2VIPConfig"
      name       = var.cluster_vip
      link       = "eth0" # the VM's only NIC (checked with: talosctl get links)
    }),
    # No kube-proxy and no Flannel: Cilium replaces both.
    yamlencode({ apiVersion = "v1alpha1", kind = "KubeProxyConfig", enabled = false }),
    yamlencode({ apiVersion = "v1alpha1", kind = "KubeFlannelCNIConfig", "$patch" = "delete" }),
    # Control planes also run workloads: drop the default node config
    # (NoSchedule taint and load-balancer exclusion label)...
    yamlencode({ apiVersion = "v1alpha1", kind = "KubeNodeConfig", "$patch" = "delete" }),
    # ...and add it back with only the control-plane role label.
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "KubeNodeConfig"
      labels     = { "node-role.kubernetes.io/control-plane" = "" }
    }),
  ]
}

# Sends the configuration to each VM (they boot in maintenance mode, waiting for it).
resource "talos_machine_configuration_apply" "this" {
  for_each                    = var.talos_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip

  # Per-node patch: fixed hostname (talos-01, talos-02, talos-03).
  config_patches = [
    yamlencode({ apiVersion = "v1alpha1", kind = "HostnameConfig", hostname = each.key, auto = "off" }),
  ]

  depends_on = [proxmox_virtual_environment_vm.talos]
}

# Starts etcd and Kubernetes. Runs once, on one node; the others join automatically.
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node

  depends_on = [talos_machine_configuration_apply.this]
}

# talosctl configuration (like a kubeconfig, but for the Talos API).
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.node_ips
  nodes                = local.node_ips
}

# kubeconfig with admin access, pointing to the VIP.
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node

  depends_on = [talos_machine_bootstrap.this]
}
