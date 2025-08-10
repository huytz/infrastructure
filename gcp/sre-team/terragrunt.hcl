include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

dependency "foundation" {
  config_path = "../foundation"
  mock_outputs = {
    project_id = "foundation-mock-project-id"
    project    = "foundation-mock-project"
  }
}

inputs = {
  foundation_project_id = dependency.foundation.outputs.project_id
  billing_account_id    = local.root_config.locals.billing_account_id
  organization_id       = local.root_config.locals.organization_id
}
