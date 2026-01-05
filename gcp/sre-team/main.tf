# SRE Team Project using the workload-project module
# This file calls the reusable workload-project module

module "workload_project" {
  source = "../../modules/gcp/workload-project"

  # Required variables
  team_name             = var.team_name
  billing_account_id    = var.billing_account_id
  organization_id       = var.organization_id
  foundation_project_id = var.foundation_project_id

  # Optional variables
  project_suffix_length = var.project_suffix_length
  required_apis         = var.required_apis
  enable_shared_vpc     = var.enable_shared_vpc
  tags                  = var.tags
}

