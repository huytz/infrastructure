variable "billing_account_id" {
  description = "The ID of the billing account to associate with projects"
  type        = string
}

variable "organization_id" {
  description = "The ID of the organization to associate with projects"
  type        = string
  default     = null
}

variable "foundation_project_id" {
  description = "The ID of the foundation project (for Shared VPC attachment)"
  type        = string
}

