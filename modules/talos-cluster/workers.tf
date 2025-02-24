locals {
  # vm_id => vm_ip
  workers = { for i in range(var.control_planes.nodes, var.control_planes.nodes + var.workers.nodes) : var.base_vm_id + i =>
    {
      ip       = "${local.ip_base}.${tonumber(local.device_ip_base) + i}"
      hostname = "worker-node-${i - var.control_planes.nodes + 1}"
  } }
}

data "talos_machine_configuration" "worker-config" {
  for_each = local.workers

  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = local.host_address
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/${var.talos_schematic_id}:${var.talos_version}"
        }

        network = {
          hostname = "${each.value.hostname}.lab53.net"
        }

        kubelet = {
          extraMounts = [
            {
              destination = "/var/local-path-provisioner"
              type        = "bind"
              source      = "/var/local-path-provisioner"
              options     = ["bind", "rshared", "rw"]
            }
          ]
        }
      }
  })]
}

resource "talos_machine_configuration_apply" "worker-node-apply" {
  for_each = local.workers

  client_configuration        = data.talos_client_configuration.client-config.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker-config[each.key].machine_configuration
  node                        = each.value.ip

  # Don't bring up worker nodes until control plane has been successfully bootstrapped
  depends_on = [module.worker-nodes, talos_machine_bootstrap.control-plane-bootstrap, data.talos_machine_configuration.worker-config]
}

module "worker-nodes" {
  for_each = local.workers
  source   = "../vm"

  id                 = each.key
  name               = each.value.hostname
  start_on_provision = true

  cpu_cores = var.workers.cores
  memory    = var.workers.memory

  disk = {
    size    = var.workers.disk_size
    file_id = proxmox_virtual_environment_download_file.talos-image.id
  }

  cloud_init = {
    username = "talos"
    network = {
      ip_address = "${each.value.ip}/24"
      gateway    = var.network.gateway_ip
    }

    dns = {
      domain = "example.com"
    }
  }
}