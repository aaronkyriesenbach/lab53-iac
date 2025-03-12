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
            cdk8s-deno = {
              generate = {
                command = ["deno", "task", "synth"]
              }
              discover = {
                fileName = "deno.json"
              }
            }
          }
        }
      }

      repoServer = {
        extraContainers = [
          {
            name    = "cdk8s-deno-cmp"
            command = ["/var/run/argocd/argocd-cmp-server"]
            image   = "denoland/deno:2.2.3"
            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }
            volumeMounts = [
              {
                name      = "plugin-config"
                mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                subPath   = "cdk8s-deno.yaml"
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
              },
              {
                name      = "cmp-tmp"
                mountPath = "/deno-dir"
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