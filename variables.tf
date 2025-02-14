variable "aws_access_key_id" {
  description = "Access key ID to authenticate to S3"
  type        = string
}

variable "aws_secret_access_key" {
  description = "Secret access key to authenticate to S3"
  type        = string
}

variable "proxmox_creds" {
  description = "Credentials for TF to connect to PVE instance"
  type = object({
    username = string,
    password = string
  })
}

variable "cloud_init_password" {
  description = "Password to use for Cloud Init user"
  type        = string
  default     = null
}