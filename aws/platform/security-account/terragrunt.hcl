include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

inputs = {
  management_account_id = local.root_config.locals.management_account_id
  
  # IAM User configuration
  create_admin_user     = true
  admin_user_name       = "admin"
  create_console_access = true
  create_access_key     = false  # Set to true if you need programmatic access
  
  tags = {
    Environment = "security"
    ManagedBy   = "Terraform"
    Type        = "Platform"
  }
}

