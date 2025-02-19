variable "seed_app" {
  description = "Configuration for app of cluster apps"
  type        = object({ name = string, repo_url = string })
}