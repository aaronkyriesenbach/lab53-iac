variable "proxmox_api_token" {
  description = "API key to authenticate to Proxmox"
  type        = string
}

variable "aws_access_key_id" {
  description = "Access key ID to authenticate to S3"
  type        = string
}

variable "aws_secret_access_key" {
  description = "Secret access key to authenticate to S3"
  type        = string
}

variable "cloud_init_password" {
  description = "Password to use for Cloud Init user"
  type        = string
  default     = null
}