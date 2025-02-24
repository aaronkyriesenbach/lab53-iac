module "talos-cluster" {
  source = "./modules/talos-cluster"

  cluster_name = "lab53-cluster"
  base_vm_id   = 500

  control_planes = {
    nodes = 1
  }

  workers = {
    nodes = 5
  }

  network = {
    base_ip    = "192.168.4.100"
    gateway_ip = "192.168.4.1"
  }
}

module "cluster-metallb" {
  source = "./modules/cluster-metallb"

  ip_pool_name      = "lab53-pool"
  ip_pool_addresses = ["192.168.4.100-192.168.4.100"]

  depends_on = [module.talos-cluster]
}

module "cluster-argocd" {
  source = "./modules/cluster-argocd"

  seed_app = {
    name     = "catalyst"
    repo_url = "https://github.com/aaronkyriesenbach/catalyst"
  }

  depends_on = [module.talos-cluster]
}