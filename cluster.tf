module "talos-cluster" {
  source = "./modules/talos-cluster"

  cluster_name = "lab53-cluster"
  base_vm_id   = 500

  control_planes = {
    nodes = 1
  }

  workers = {
    nodes = 3
  }

  network = {
    base_ip    = "192.168.4.100"
    gateway_ip = "192.168.4.1"
  }
}

resource "local_file" "talosconfig" {
  filename = "output/talosconfig"
  content  = module.talos-cluster.talos_config
}

resource "local_file" "kubeconfig" {
  filename = "output/kubeconfig"
  content  = module.talos-cluster.kubeconfig
}

resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  namespace        = "argocd"
  create_namespace = true
}