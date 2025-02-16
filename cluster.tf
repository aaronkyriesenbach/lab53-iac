locals {
  cluster_name = "lab53-cluster"
  schematic_id = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  talos_version = "v1.9.4"
}

data "talos_image_factory_urls" "talos-urls" {
  talos_version = local.talos_version
  schematic_id = local.schematic_id
  platform = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "talos-image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = data.talos_image_factory_urls.talos-urls.urls.iso
}

resource "talos_machine_secrets" "secrets" {}

data "talos_client_configuration" "client-config" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

data "talos_machine_configuration" "control-plane-config" {
  cluster_name     = local.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${module.control-plane.ipv4_address}:6443"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${local.schematic_id}:${local.talos_version}"
        }
      }
  })]
}

resource "talos_machine_configuration_apply" "control-plane-apply" {
  client_configuration        = data.talos_client_configuration.client-config.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control-plane-config.machine_configuration
  node                        = module.control-plane.ipv4_address

  depends_on = [module.control-plane]
}

resource "talos_machine_bootstrap" "control-plane-bootstrap" {
  client_configuration = data.talos_client_configuration.client-config.client_configuration
  node                 = module.control-plane.ipv4_address

  depends_on = [talos_machine_configuration_apply.control-plane-apply]
}

module "control-plane" {
  source = "./modules/vm"

  id                 = 500
  name               = "control-plane"
  start_on_provision = true

  cpu_cores = 4

  memory = 16

  disk = {
    size    = 16
    file_id = proxmox_virtual_environment_download_file.talos-image.id
  }

  cloud_init = {
    username = "talos"
    network = {
      ip_address = "192.168.4.100/24"
      gateway    = local.gateway_ip
    }
  }
}

data "talos_machine_configuration" "worker-config" {
  cluster_name     = local.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${module.control-plane.ipv4_address}:6443"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${local.schematic_id}:${local.talos_version}"
        }
      }
    })]
}

resource "talos_machine_configuration_apply" "worker-node-apply" {
  count = 2

  client_configuration        = data.talos_client_configuration.client-config.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker-config.machine_configuration
  node                        = "192.168.4.${101 + count.index}"

  # Don't bring up worker nodes until control plane has been successfully bootstrapped
  depends_on = [talos_machine_bootstrap.control-plane-bootstrap]
}

module "worker-node" {
  count = 2

  source = "./modules/vm"

  id                 = 501 + count.index
  name               = "worker-node-${count.index + 1}"
  start_on_provision = true

  cpu_cores = 2
  memory    = 8

  disk = {
    size    = 16
    file_id = proxmox_virtual_environment_download_file.talos-image.id
  }

  cloud_init = {
    username = "talos"
    network = {
      ip_address = "192.168.4.${101 + count.index}/24"
      gateway    = local.gateway_ip
    }
  }
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = data.talos_client_configuration.client-config.client_configuration
  node = module.control-plane.ipv4_address
}

resource "local_file" "talosconfig" {
  filename = "output/talosconfig"
  content = data.talos_client_configuration.client-config.talos_config
}

resource "local_file" "kubeconfig" {
  filename = "output/kubeconfig"
  content = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
}