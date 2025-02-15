data "ct_config" "docker-flatcar-config" {
  content = file("config/base.yml")

  snippets = [
    templatefile("config/hostname.yml", { hostname = "docker-flatcar" }),
    file("config/docker.yml")
  ]
}

module "docker-flatcar" {
  source = "./modules/flatcar-vm"

  id   = 505
  name = "docker-flatcar"

  ignition_config = data.ct_config.docker-flatcar-config.rendered
}