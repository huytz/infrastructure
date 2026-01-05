# Example: Production Account using Workload Account Module
# This shows how to use the module to create a new workload account

module "production_account" {
  source = "../../../aws/workload-account"

  # Required variables
  account_name              = "production"
  vpc_cidr                 = "10.2.0.0/16"
  network_account_vpc_id    = var.network_account_vpc_id
  network_account_vpc_cidr  = var.network_account_vpc_cidr
  transit_gateway_id       = var.transit_gateway_id

  # Optional variables
  aws_region               = "us-east-1"
  environment              = "production"
  enable_flow_logs         = true
  flow_logs_retention_days = 14

  # Additional tags
  tags = {
    Environment = "production"
    Team        = "Platform"
    CostCenter  = "Engineering"
    Project     = "Production"
  }
}

# Outputs
output "vpc_id" {
  value = module.production_account.vpc_id
}

output "private_subnet_ids" {
  value = module.production_account.private_subnet_ids
}

