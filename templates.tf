resource "proxmox_virtual_environment_download_file" "debian_base_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://lab53-iac.s3.us-east-1.amazonaws.com/debian-12-generic-amd64.qcow2"
  file_name    = "debian-12-generic-amd64.qcow2.img"
  overwrite    = true
}

module "debian-template" {
  source = "./modules/vm"

  id   = 100
  name = "debian12-template"

  template = true

  disk = {
    file_id = proxmox_virtual_environment_download_file.debian_base_image.id
  }

  cloud_init = {
    password : var.cloud_init_password
  }
}