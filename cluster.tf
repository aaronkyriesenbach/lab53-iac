module "talos-cluster" {
  source = "./modules/talos-cluster"

  cluster_name = "lab53-cluster"
  base_vm_id = 500

  control_planes = {
    nodes = 1
  }

  workers = {
    nodes = 3
  }

  network = {
    base_ip = "192.168.4.100"
    gateway_ip = "192.168.4.1"
  }
}

resource "local_file" "talosconfig" {
  filename = "output/talosconfig"
  content = module.talos-cluster.talosconfig
}

resource "local_file" "kubeconfig" {
  filename = "output/kubeconfig"
  content = module.talos-cluster.kubeconfig
}