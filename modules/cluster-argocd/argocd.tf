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
        exec = {
          enabled = true
        }
      }
    }
  })]
}

resource "kubectl_manifest" "seed-app" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.seed_app.name
      namespace = "argocd"
    }

    spec = {
      project = "default"

      destination = {
        server = "https://kubernetes.default.svc"
      }

      source = {
        repoURL = var.seed_app.repo_url
        path    = "."
      }

      syncPolicy = {
        automated = {
          prune    = true
        }
      }
    }
  })

  depends_on = [helm_release.argocd]
}