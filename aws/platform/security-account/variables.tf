variable "management_account_id" {
  description = "AWS Account ID of the management account"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_admin_user" {
  description = "Whether to create an admin IAM user for console access"
  type        = bool
  default     = false
}

variable "admin_user_name" {
  description = "Name of the admin IAM user to create"
  type        = string
  default     = "admin"
}

variable "create_console_access" {
  description = "Whether to create console login profile for the admin user"
  type        = bool
  default     = true
}

variable "create_access_key" {
  description = "Whether to create access key for programmatic access"
  type        = bool
  default     = false
}

