# -----------------------------------------------------------------------------
# PROXMOX API VARIABLES (These will be provided by Semaphore)
# -----------------------------------------------------------------------------
variable "proxmox_api_url" {
  type        = string
  description = "The URL for the Proxmox API (e.g., https://192.168.1.10:8006/api2/json)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The API token ID for authenticating with Proxmox."
  sensitive   = true

variable "proxmox_api_token_secret" {
  type        = string
  description = "The secret for the Proxmox API token."
  sensitive   = true
}

# -----------------------------------------------------------------------------
# INFRASTRUCTURE CONFIGURATION VARIABLES (You can change these defaults)
# -----------------------------------------------------------------------------
variable "proxmox_target_node" {
  type        = string
  description = "The name of the Proxmox node where the VMs will be created."
  default     = "pve2" # IMPORTANT: Change "pve" to the name of your Proxmox node if it's different.
}

variable "talos_template_name" {
  type        = string
  description = "The name of the Talos VM template in Proxmox to clone."
  default     = "talos-template" # IMPORTANT: Change this if you named your template something else.
}

variable "controlplane_count" {
  type        = number
  description = "Number of control plane nodes to create."
  default     = 1
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes to create."
  default     = 2
}

variable "cluster_name" {
  type        = string
  description = "A name for your Talos Kubernetes cluster."
  default     = "my-talos-cluster"
}

variable "talos_version" {
  type        = string
  description = "The version of Talos OS to use (should match your template)."
  default     = "v1.7.0" # IMPORTANT: Change this to match the version you downloaded.
}