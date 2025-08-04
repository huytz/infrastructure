include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

inputs = {
  billing_account_id = local.root_config.locals.billing_account_id
}
