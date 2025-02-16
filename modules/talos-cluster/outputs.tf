output "talosconfig" {
  description = "Talos config for provisioned cluster"
  value       = data.talos_client_configuration.client-config.talos_config
}

output "kubeconfig" {
  description = "Kubeconfig for provisioned cluster"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
}