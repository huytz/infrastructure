variable "billing_account_id" {
  description = "The ID of the billing account to associate with the project"
  type        = string
}

variable "organization_id" {
  description = "The ID of the organization to associate with the project"
  type        = string
  default     = null
}

variable "foundation_project_id" {
  description = "The ID of the foundation project"
  type        = string
}
