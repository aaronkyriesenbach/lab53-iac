variable "metallb_namespace" {
  description = "Namespace to install MetalLB in"
  type        = string
  default     = "metallb-system"
}

variable "ip_pool_name" {
  description = "Name of IP address pool"
  type        = string
}

variable "ip_pool_addresses" {
  description = "List of IP addresses to use for pool"
  type        = list(string)
}