# GCP Root Configuration
# This file is included by all GCP project configurations

locals {
  # Get environment from path or default
  environment = try(basename(path_relative_to_include()), "default")

  # GCP credentials and configuration
  gcp_project_id  = get_env("GCP_PROJECT_ID", "")
  gcp_region      = get_env("GCP_REGION", "us-central1")
  gcp_credentials = get_env("GCP_CREDENTIALS", "")

  # Common configuration
  billing_account_id = get_env("BILLING_ACCOUNT_ID", "")
  organization_id    = get_env("ORGANIZATION_ID", "")

  # GCP provider configuration
  # Credentials are read from GCP_* environment variables
  # Set GCP_PROJECT_ID, GCP_REGION, GCP_CREDENTIALS (or GOOGLE_CREDENTIALS)
  gcp_provider = <<-EOF
provider "google" {
  project = var.project_id != "" ? var.project_id : (var.gcp_project_id != "" ? var.gcp_project_id : null)
  region  = var.region != "" ? var.region : (var.gcp_region != "" ? var.gcp_region : "us-central1")
}
EOF
}

# Generate versions.tf - GCP-specific provider versions
generate "versions" {
  path           = "versions.tf"
  if_exists      = "overwrite_terragrunt"
  comment_prefix = "#"
  contents       = <<EOF
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}
EOF
}

# Generate provider.tf with GCP provider configuration
generate "provider" {
  path           = "provider.tf"
  if_exists      = "overwrite_terragrunt"
  comment_prefix = "#"
  contents       = local.gcp_provider
}

