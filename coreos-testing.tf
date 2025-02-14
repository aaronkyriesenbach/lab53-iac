data "ct_config" "test-1-config" {
  content = file("coreos.yaml")
}

module "coreos-test-1" {
  source = "./modules/fedora-coreos-vm"

  id   = 501
  name = "coreos-test-1"

  ignition_config = data.ct_config.test-1-config.rendered
}

data "ct_config" "test-2-config" {
  content = file("coreos2.yaml")
}

module "coreos-test-2" {
  source = "./modules/fedora-coreos-vm"

  id   = 502
  name = "coreos-test-2"

  ignition_config = data.ct_config.test-2-config.rendered
}