locals {
  metadata = jsondecode(data.http.coreos_stable_metadata.response_body)

  coreos_qemu_stable = local.metadata.architectures.x86_64.artifacts.qemu.formats["qcow2.xz"].disk
  download_url       = local.coreos_qemu_stable.location
  download_sum       = local.coreos_qemu_stable.sha256

  kvm_args = var.ignition_config != null ? "-fw_cfg 'name=opt/com.coreos/config,string=${replace(var.ignition_config, ",", ",,")}'" : null
}

data "http" "coreos_stable_metadata" {
  url = "https://builds.coreos.fedoraproject.org/streams/stable.json"
}

resource "proxmox_virtual_environment_download_file" "coreos_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url      = local.download_url
  checksum = local.download_sum

  checksum_algorithm      = "sha256"
  decompression_algorithm = "zst"

  file_name = "${basename(local.download_url)}.img"

  overwrite = false
}

module "coreos-vm" {
  source = "../vm"

  id            = var.id
  name          = var.name
  machine_type  = var.machine_type
  start_on_boot = var.start_on_boot

  cpu_cores = var.cpu_cores
  memory    = var.memory

  disk = {
    size = var.disk.size

    file_id = proxmox_virtual_environment_download_file.coreos_img.id
  }

  agent_enabled = false
  cloud_init = {
    enabled = false
  }

  kvm_arguments = local.kvm_args
}