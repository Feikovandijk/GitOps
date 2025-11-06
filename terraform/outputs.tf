# Output the static IPs assigned to control plane nodes
output "controlplane_ips" {
  description = "The static IP addresses of the control plane nodes."
  value = [
    for i in range(var.controlplane_count) : "10.0.0.${151 + i}"
  ]
}

# Output the control plane node names
output "controlplane_names" {
  description = "The names of the control plane nodes."
  value       = proxmox_vm_qemu.controlplane[*].name
}

# This output will display a list of the IP addresses assigned to the worker nodes (DHCP).
# Note: May be empty initially until VMs boot and receive DHCP addresses.
output "worker_ips" {
  description = "The DHCP IP addresses of the worker nodes (may take time to populate)."
  value       = proxmox_vm_qemu.worker[*].default_ipv4_address
}

# Output the worker node names
output "worker_names" {
  description = "The names of the worker nodes."
  value       = proxmox_vm_qemu.worker[*].name
}

# Output the cluster endpoint VIP
output "cluster_endpoint" {
  description = "The Kubernetes API endpoint (VIP managed by Talos)."
  value       = "https://10.0.0.150:6443"
}

# This output will print the contents of the 'talosconfig' file.
output "talosconfig" {
  description = "Talos client configuration. Save this to a file named 'talosconfig'."
  value       = talos_machine_secrets.secrets.talosconfig
  sensitive   = true # Hides this from the normal Terraform plan output for security
}