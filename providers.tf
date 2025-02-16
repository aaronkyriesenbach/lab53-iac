terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    talos = {
      source = "siderolabs/talos"
    }
    local = {
      source = "hashicorp/local"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }

  backend "s3" {
    region     = "us-east-1"
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key

    bucket = "lab53-iac"
    key    = "tf-state"
  }
}

provider "proxmox" {
  endpoint = "https://192.168.4.81:8006"
  insecure = true # Running against IP with PVE self-signed cert

  username = var.proxmox_creds.username
  password = var.proxmox_creds.password
}

provider "helm" {
  kubernetes {
    config_path = "output/kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "output/kubeconfig"
}