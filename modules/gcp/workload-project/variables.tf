variable "team_name" {
  description = "Name of the workload team (e.g., sre, production, staging)"
  type        = string
}

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
  description = "The ID of the foundation project (for Shared VPC attachment)"
  type        = string
}

variable "project_suffix_length" {
  description = "Length of random suffix for project ID"
  type        = number
  default     = 4
}

variable "required_apis" {
  description = "List of Google Cloud APIs to enable"
  type        = list(string)
  default = [
    "container.googleapis.com",            # Kubernetes Engine API
    "compute.googleapis.com",              # Compute Engine API
    "iam.googleapis.com",                  # Identity and Access Management API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "servicenetworking.googleapis.com",    # Service Networking API
    "dns.googleapis.com",                  # Cloud DNS API
    "logging.googleapis.com",              # Cloud Logging API
    "monitoring.googleapis.com",           # Cloud Monitoring API
    "artifactregistry.googleapis.com"      # Artifact Registry API
  ]
}

variable "enable_shared_vpc" {
  description = "Enable Shared VPC attachment to foundation project"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags/labels to apply to the project"
  type        = map(string)
  default     = {}
}

