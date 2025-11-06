terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
  }
}

# This block configures the Proxmox provider.
# Semaphore should provide the values for these variables.
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true #self-signed cert
}

# -----------------------------------------------------------------------------
# TALOS CONFIGURATION GENERATION
# These resources don't create VMs. Instead, they generate the secure YAML
# configuration files that each Talos node needs to boot up and form a cluster.
# -----------------------------------------------------------------------------

resource "talos_machine_secrets" "secrets" {}

# This generates the configuration for the control plane nodes.
resource "talos_machine_configuration" "controlplane_config" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://10.0.0.150:6443" # VIP for the cluster (static IP outside DHCP pool)
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  talos_version    = var.talos_version
}

# This generates the configuration for the worker nodes.
resource "talos_machine_configuration" "worker_config" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://10.0.0.150:6443" # This MUST match the control plane endpoint.
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  talos_version    = var.talos_version
}

# -----------------------------------------------------------------------------
# PROXMOX VIRTUAL MACHINE CREATION
# These 'resource' blocks are the blueprints for the actual VMs.
# -----------------------------------------------------------------------------

# This block creates the control plane VM(s).
resource "proxmox_vm_qemu" "controlplane" {
  count = var.controlplane_count # Creates as many as the 'controlplane_count' variable says

  name        = "talos-cp-${count.index}" # e.g., talos-cp-0
  target_node = var.proxmox_target_node # Uses the node name from our variables
  clone       = var.talos_template_name # Uses the template name from our variables

  # VM settings
  agent   = 1    # Enable the QEMU guest agent
  os_type = "cloud-init"
  cores   = 2
  sockets = 1
  memory  = 2048 # 2GB RAM

  # Network settings
  network {
    model  = "virtio"
    bridge = "vmbr0" # Assumes your Proxmox bridge is named vmbr0
  }

  # Cloud-Init: Static IP assignment for control plane nodes (10.0.0.151+)
  # First node gets .151, second gets .152, etc.
  ipconfig0 = "ip=10.0.0.${151 + count.index}/24,gw=10.0.0.1"
  # 'user_data' is a special cloud-init field. The 'heredoc' (<<-EOT) syntax
  # makes it easy to write multi-line strings.
  user_data = <<-EOT
    #cloud-config
    user_data:
      version: v1alpha1
      config: |
        ${talos_machine_configuration.controlplane_config.machine_configuration}
  EOT
}

# This block creates the worker VM(s).
resource "proxmox_vm_qemu" "worker" {
  count = var.worker_count # Creates as many as the 'worker_count' variable says

  name        = "talos-worker-${count.index}" # e.g., talos-worker-0, talos-worker-1
  target_node = var.proxmox_target_node
  clone       = var.talos_template_name

  # VM settings
  agent   = 1
  os_type = "cloud-init"
  cores   = 2
  sockets = 1
  memory  = 4096 # 4GB RAM

  # Network settings
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-Init for the worker nodes
  ipconfig0 = "ip=dhcp"
  user_data = <<-EOT
    #cloud-config
    user_data:
      version: v1alpha1
      config: |
        ${talos_machine_configuration.worker_config.machine_configuration}
  EOT
}