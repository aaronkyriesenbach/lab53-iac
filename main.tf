locals {
  gateway_ip = "192.168.4.1"
}

module "docker" {
  source = "./modules/vm"

  name = "docker"
  id   = 200

  cpu_cores = 2
  memory    = 16

  disk = {
    size = 16
  }

  cloud_init = {
    password = var.cloud_init_password,
    network = {
      ip_address = "192.168.4.82/24",
      gateway    = local.gateway_ip
    }
  }
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "h710" {
  name = "h710"

  map = [{
    id           = "1000:0087"
    node         = "pve"
    path         = "0000:03:00.0"
    iommu_group  = 21
    subsystem_id = "1028:1f35"
  }]
}

module "truenas" {
  source = "./modules/vm"

  name = "truenas"
  id   = 400

  machine_type  = "q35"
  agent_enabled = false

  cpu_cores = 4
  memory    = 128

  disk = {
    size = 32
    format = "raw"
  }

  pci_mappings = {
    hostpci0 = {
      mapping = "h710",
      pcie    = true
    }
  }

  cloud_init = {
    enabled = false
  }
}
