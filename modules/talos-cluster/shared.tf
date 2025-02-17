locals {
  ip_base_split  = split(".", var.network.base_ip)
  ip_base        = join(".", slice(local.ip_base_split, 0, 3))
  device_ip_base = local.ip_base_split[3]

  control_plane_ip = local.control_planes[var.base_vm_id]

  host_address = "https://${local.control_plane_ip}:6443"
}

data "talos_image_factory_urls" "talos-urls" {
  talos_version = var.talos_version
  schematic_id  = var.talos_schematic_id
  platform      = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "talos-image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = data.talos_image_factory_urls.talos-urls.urls.iso
}

resource "talos_machine_secrets" "secrets" {}

data "talos_client_configuration" "client-config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = data.talos_client_configuration.client-config.client_configuration

  node = local.control_plane_ip
}