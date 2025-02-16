output "ipv4_address" {
  description = "IPV4 address set by Cloud-Init"
  value       = split("/", var.cloud_init.network.ip_address)[0]
}