include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

dependency "organizations" {
  config_path = find_in_parent_folders("aws/organizations")
  skip_outputs = false
  
  mock_outputs = {
    organization_id = "o-mock123456"
    root_id         = "r-mock123456"
  }
}

inputs = {
  aws_region  = local.root_config.locals.aws_region
  environment = "management"
  
  # Bucket names (from root.hcl)
  cloudtrail_log_bucket_name = local.root_config.locals.cloudtrail_log_bucket_name
  
  enable_security_controls = true
  enable_scps             = true
  enable_identity_center  = true  # Enable AWS IAM Identity Center (AWS SSO)
  
  tags = {
    Environment = "management"
    ManagedBy   = "Terraform"
    Type        = "Platform"
  }
}

