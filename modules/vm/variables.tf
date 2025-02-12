variable "id" {
  description = "ID of the VM"
  type        = number
}

variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "start_on_boot" {
  description = "Whether to start VM on node boot"
  type        = bool
  default     = true
}

variable "clone" {
  description = "Clone configuration"
  type = object({
    enabled    = optional(bool, false)
    base_vm_id = optional(number)
  })
  default = {}

  validation {
    condition     = var.clone.enabled == false || var.clone.base_vm_id != null
    error_message = "If clone is enabled, base VM ID must be provided"
  }
}

variable "cpu_cores" {
  description = "Cores to provide to VM"
  type        = number
  default     = 1
}

variable "disk" {
  description = "Drive parameters"
  type = object({
    size         = optional(number, 8),
    file_id      = optional(string)
  })
  default = {}
}

variable "cloud_init" {
  description = "Cloud init config for provisioned VMs"
  type = object({
    enabled  = optional(bool, true)
    keys     = optional(set(string), ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlMOweDhWjna70PMFtxxKEXhHCXGP1P9CfYIKn5gl+6 aaronkyriesenbach@pobox.com"])
    username = optional(string, "aaron")
    password = optional(string)
  })
  default = {}
}

variable "memory" {
  description = "Memory to provide to VM (GB)"
  type        = number
  default     = 0.5
}

variable "os_type" {
  description = "VM's OS type"
  type        = string
  default     = "l26"
}

variable "machine_type" {
  description = "VM machine type"
  type        = string
  default     = "pc"
}

variable "agent_enabled" {
  description = "Whether QEMU guest agent is enabled"
  type        = bool
  default     = true
}

variable "pci_mappings" {
  description = "Mappings for PCI devices to pass to VM"
  type = map(object({
    mapping = string,
    pcie    = optional(bool, false)
  }))
  default = {}
}

variable "template" {
  description = "Create this VM as a template"
  type        = bool
  default     = false
}