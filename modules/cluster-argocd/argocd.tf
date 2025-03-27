resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      global = {
        domain = "argo.lab53.net"
      }

      configs = {
        cm = {
          "kustomize.buildOptions" = "--enable-helm"
          exec = {
            enabled = true
          }
        }
      }

      repoServer = {
        extraContainers = [
          {
            name  = "cdk8s-deno-cmp"
            image = "ghcr.io/aaronkyriesenbach/argocd-cdk8s-deno-plugin:v1.0.0-snapshot"
            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }
            volumeMounts = [
              {
                name      = "var-files"
                mountPath = "/var/run/argocd"
              },
              {
                name      = "plugins"
                mountPath = "/home/argocd/cmp-server/plugins"
              },
              {
                name      = "cmp-tmp"
                mountPath = "/tmp"
              }
            ]
          }
        ]

        volumes = [
          {
            name = "cmp-tmp"
            emptyDir = {}
          }
        ]
      }
    })
  ]
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
    }
  })

  depends_on = [helm_release.argocd]
}