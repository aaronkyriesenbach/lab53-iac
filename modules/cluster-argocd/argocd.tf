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

        cmp = {
          create = true
          plugins = {
            cdk8s-typescript = {
              init = {
                command = ["sh", "-c"]
                args    = ["npm install && cd ../shared && npm install"]
              }
              generate = {
                command = ["cdk8s", "synth"]
                args    = ["--stdout"]
              }
              discover = {
                fileName = "*.ts"
              }
            }
          }
        }
      }

      repoServer = {
        extraContainers = [
          {
            name    = "cdk8s-cmp"
            command = ["/var/run/argocd/argocd-cmp-server"]
            image   = "ghcr.io/akuity/cdk8s-cmp-typescript:latest"
            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }
            volumeMounts = [
              {
                name      = "plugin-config"
                mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                subPath   = "cdk8s-typescript.yaml"
              },
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
            name = "plugin-config"
            configMap = {
              name = "argocd-cmp-cm"
            }
          },
          {
            name     = "cmp-tmp"
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