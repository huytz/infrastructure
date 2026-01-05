variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "network_name" {
  description = "The name of the network"
  type        = string
}

variable "subnet_configurations" {
  description = "The subnet configurations"
  type        = string
}

variable "foundation_project_id" {
  description = "The ID of the foundation project"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region (fallback from environment variable GCP_REGION)"
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "GCP project ID (fallback from environment variable GCP_PROJECT_ID)"
  type        = string
  default     = ""
}