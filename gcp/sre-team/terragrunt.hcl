include "root" {
  path = find_in_parent_folders("gcp/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("gcp/root.hcl"))
}

dependency "foundation" {
  config_path = find_in_parent_folders("gcp/foundation")
  mock_outputs = {
    project_id = "foundation-mock-project-id"
    project    = "foundation-mock-project"
  }
}

# Terragrunt will use the files in this directory (main.tf, variables.tf, outputs.tf)
# The main.tf calls the workload-project module

inputs = {
  # Required variables
  team_name             = "sre-team"
  billing_account_id    = local.root_config.locals.billing_account_id
  organization_id       = local.root_config.locals.organization_id
  foundation_project_id = dependency.foundation.outputs.project_id

  # Optional variables - using defaults
  # project_suffix_length = 4
  # required_apis = [...] (using module defaults)
  # enable_shared_vpc = true

  # Optional: Add custom tags
  tags = {
    Team = "SRE"
  }
}
