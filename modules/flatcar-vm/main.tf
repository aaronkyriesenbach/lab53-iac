locals {
  download_url = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img"

  kvm_args = var.ignition_config != null ? "-fw_cfg 'name=opt/org.flatcar-linux/config,string=${replace(var.ignition_config, ",", ",,")}'" : null
}

resource "proxmox_virtual_environment_download_file" "flatcar_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = local.download_url
}

module "flatcar-vm" {
  source = "../vm"

  id            = var.id
  name          = var.name
  machine_type  = var.machine_type
  start_on_boot = var.start_on_boot

  cpu_cores = var.cpu_cores
  memory    = var.memory

  disk = {
    size = var.disk.size

    file_id = proxmox_virtual_environment_download_file.flatcar_img.id
  }

  agent_enabled = false
  cloud_init = {
    enabled = false
  }

  kvm_arguments = local.kvm_args
}