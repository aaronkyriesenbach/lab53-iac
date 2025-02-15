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
    password = var.cloud_init_password
  }
}

module "k3s" {
  source = "./modules/vm"

  name          = "k3s"
  id            = 201
  start_on_boot = false

  cpu_cores = 2
  memory    = 8

  disk = {
    size = 16
  }

  cloud_init = {
    password = var.cloud_init_password
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
  id   = 202

  machine_type  = "q35"
  agent_enabled = false

  cpu_cores = 4
  memory    = 128

  disk = {
    size = 32
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

module "docker-public" {
  source = "./modules/vm"

  name = "docker-public"
  id   = 300

  cpu_cores = 4
  memory    = 32

  disk = {
    size = 48
  }

  cloud_init = {
    password = var.cloud_init_password
  }
}