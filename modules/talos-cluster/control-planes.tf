locals {
  # vm_id => vm_ip
  control_planes = { for i in range(var.control_planes.nodes) : var.base_vm_id + i => "${local.ip_base}.${tonumber(local.device_ip_base) + i}" }
}

data "talos_machine_configuration" "control-plane-config" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.control_planes[var.base_vm_id]}:6443"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}"
        }
      }
  })]
}

resource "talos_machine_configuration_apply" "control-plane-applies" {
  for_each = local.control_planes

  client_configuration        = data.talos_client_configuration.client-config.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control-plane-config.machine_configuration

  node = each.value

  depends_on = [module.control-planes]
}

resource "talos_machine_bootstrap" "control-plane-bootstrap" {
  client_configuration = data.talos_client_configuration.client-config.client_configuration

  # Bootstrap only needs to be performed on one node, so we use the first control plane
  node = local.control_planes[var.base_vm_id]

  depends_on = [talos_machine_configuration_apply.control-plane-applies]
}

module "control-planes" {
  for_each = local.control_planes
  source   = "../vm"

  id                 = each.key
  name               = "control-plane-${each.key - var.base_vm_id + 1}"
  start_on_provision = true

  cpu_cores = var.control_planes.cores
  memory    = var.control_planes.memory

  disk = {
    size    = var.control_planes.disk_size
    file_id = proxmox_virtual_environment_download_file.talos-image.id
  }

  cloud_init = {
    username = "talos"
    network = {
      ip_address = "${each.value}/24"
      gateway    = var.network.gateway_ip
    }
  }
}