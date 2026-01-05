include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

inputs = {
  aws_region = local.root_config.locals.aws_region
  
  # IaC Execution Account ID (from root.hcl)
  iac_execution_account_id = local.root_config.locals.iac_execution_account_id
  
  # Workload environments for Transit Gateway route table isolation
  # Each environment specifies its VPC CIDR and environment type (development/sandbox/production)
  workload_environments = {
    sre = {
      vpc_cidr    = "10.1.0.0/16"
      environment = "development"
    }
    sandbox = {
      vpc_cidr    = "10.4.0.0/16"
      environment = "sandbox"
    }
  }
}

