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

variable "cpu_cores" {
  description = "Cores to provide to VM"
  type        = number
  default     = 1
}

variable "disk" {
  description = "Drive parameters"
  type = object({
    size    = optional(number, 16),
    file_id = optional(string)
  })
  default = {}
}

variable "memory" {
  description = "Memory to provide to VM (GB)"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "VM machine type"
  type        = string
  default     = "pc"
}

variable "ignition_config" {
  description = "Rendered Ignition config to pass to VM via KVM args"
  type        = string
  default     = null
}