include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

inputs = {
  environment = "organizations"
  aws_region  = local.root_config.locals.aws_region
  
  # Enable account creation
  enable_account_creation = true
  
  # Map accounts to OUs - accounts will be created in these OUs (if enable_account_creation = true)
  # Note: Security account already exists, so it's excluded from this mapping
  # Note: Route table assignment is handled by each workload account individually
  account_ou_mapping = {
    network = "platform"
    logging = "platform"
    sre     = "workloads/dev"
  }
  
  # Organizational Units configuration
  organizational_units = {
    platform = {
      name        = "Platform"
      description = "Platform accounts (Security, Network, Logging)"
    }
    workloads = {
      name        = "Workloads"
      description = "Workload accounts (Dev, Test, Prod)"
    }
  }
  
  # Workload sub-OUs
  workload_ous = {
    dev = {
      name        = "Dev"
      description = "Development environment accounts"
    }
    sandbox = {
      name        = "Sandbox"
      description = "Testing environment accounts"
    }
    prod = {
      name        = "Prod"
      description = "Production environment accounts"
    }
  }
}

