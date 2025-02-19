# The namespace must be created prior to MetalLB install because it requires elevated permissions
resource "kubectl_manifest" "metallb-system-namespace" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.metallb_namespace
      labels = {
        name                                 = var.metallb_namespace
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/audit"   = "privileged"
        "pod-security.kubernetes.io/warn"    = "privileged"
      }
    }
  })
}

resource "helm_release" "metallb" {
  chart      = "metallb"
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"

  namespace = var.metallb_namespace

  depends_on = [kubectl_manifest.metallb-system-namespace]
}

resource "kubectl_manifest" "metallb-ipaddresspool" {
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = var.ip_pool_name
      namespace = var.metallb_namespace
    }
    spec = {
      addresses = var.ip_pool_addresses
    }
  })

  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb-l2advertisement" {
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "${var.ip_pool_name}-advertisement"
      namespace = var.metallb_namespace
    }
  })

  depends_on = [helm_release.metallb]
}