variable "billing_account_id" {
  description = "The ID of the billing account"
  type        = string
}

variable "organization_id" {
  description = "The ID of the organization"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Name for the Cloud DNS managed zone (e.g., foundation-internal). Defaults to foundation-internal"
  type        = string
  default     = ""
}

variable "dns_domain_name" {
  description = "DNS domain name for the managed zone (e.g., foundation.internal.). Defaults to foundation.internal."
  type        = string
  default     = ""
}

variable "initial_dns_records" {
  description = "Initial DNS records to create in the managed zone. Format: { name = { name = \"hostname\", type = \"A\", ttl = 300, rrdatas = [\"10.0.1.10\"] } }"
  type = map(object({
    name    = string
    type    = string
    ttl     = number
    rrdatas = list(string)
  }))
  default = {}
}

variable "project_id" {
  description = "The GCP project ID. If not provided, will use the project created by this module."
  type        = string
  default     = ""
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "gcp_project_id" {
  description = "GCP project ID (fallback from environment variable GCP_PROJECT_ID)"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region (fallback from environment variable GCP_REGION)"
  type        = string
  default     = ""
}