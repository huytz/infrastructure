generate "terraform" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.38.0, < 7.0.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.0"
    }
  }
}

EOF
}

locals {
  billing_account_id = get_env("BILLING_ACCOUNT_ID")
  organization_id    = get_env("ORGANIZATION_ID")
}

