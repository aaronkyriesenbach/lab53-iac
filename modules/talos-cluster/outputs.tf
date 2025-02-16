output "client_config" {
  description = "ca_certificate, client_certificate, and client_key for cluster"
  value       = talos_machine_secrets.secrets.client_configuration
}

output "talos_config" {
  description = "Talos config for provisioned cluster"
  value       = data.talos_client_configuration.client-config.talos_config
}

output "kubeconfig" {
  description = "Kubeconfig for provisioned cluster"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
}