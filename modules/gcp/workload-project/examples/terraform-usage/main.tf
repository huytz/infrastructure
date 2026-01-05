# Example Terraform configuration for using the workload-project module

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.38.0, < 7.0.0"
    }
  }
}

# Example: Create a production team project
module "production_team" {
  source = "../../"

  # Required variables
  team_name              = "production"
  billing_account_id     = var.billing_account_id
  organization_id        = var.organization_id
  foundation_project_id   = var.foundation_project_id

  # Optional variables
  tags = {
    environment = "production"
    team        = "platform"
    cost_center = "engineering"
  }
}

# Example: Create a staging team project
module "staging_team" {
  source = "../../"

  team_name              = "staging"
  billing_account_id     = var.billing_account_id
  organization_id        = var.organization_id
  foundation_project_id   = var.foundation_project_id

  tags = {
    environment = "staging"
    team        = "platform"
  }
}

