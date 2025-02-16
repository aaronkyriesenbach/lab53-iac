variable "control_planes" {
  description = "Configuration for control plane nodes"
  type = object({
    nodes     = number,
    cores     = optional(number, 4)
    memory    = optional(number, 16)
    disk_size = optional(number, 16)
  })
}

variable "workers" {
  description = "Configuration for worker nodes"
  type = object({
    nodes     = number,
    cores     = optional(number, 2)
    memory    = optional(number, 8)
    disk_size = optional(number, 16)
  })
}

variable "network" {
  description = "Networking config for nodes"
  type = object({
    base_ip    = string,
    gateway_ip = string
  })
}

variable "base_vm_id" {
  description = "Starting Proxmox VM ID for nodes"
  type        = number
}

variable "talos_version" {
  description = "Version of Talos OS to use for nodes"
  type        = string
  default     = "v1.9.4"
}

variable "talos_schematic_id" {
  description = "Talos Image Factory schematic ID to use"
  type        = string
  default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515" # Applies qemu-guest-agent customization
}

variable "cluster_name" {
  description = "Name of cluster to provison"
  type        = string
}