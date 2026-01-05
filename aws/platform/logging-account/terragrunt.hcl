include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

inputs = {
  aws_region  = local.root_config.locals.aws_region
  environment = "logging"
  
  # Bucket names (from root.hcl)
  cloudtrail_log_bucket_name = local.root_config.locals.cloudtrail_log_bucket_name
  config_log_bucket_name     = local.root_config.locals.config_log_bucket_name
  
  flow_logs_retention_days = 90
  
  tags = {
    Environment = "logging"
    ManagedBy   = "Terraform"
    Type        = "Platform"
  }
}

