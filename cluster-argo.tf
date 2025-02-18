resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  namespace        = "argocd"
  create_namespace = true

  values = [yamlencode({
    configs = {
      cm = {
        "kustomize.buildOptions" = "--enable-helm"
      }
    }
  })]

  depends_on = [module.talos-cluster, helm_release.metallb]
}

resource "kubectl_manifest" "catalyst" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "catalyst"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      destination = {
        server = "https://kubernetes.default.svc"
      }

      source = {
        repoURL = "https://github.com/aaronkyriesenbach/catalyst"
        path    = "."
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  })

  depends_on = [helm_release.argocd]
}