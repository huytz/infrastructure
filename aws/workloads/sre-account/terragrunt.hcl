include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

dependency "network_account" {
  config_path = find_in_parent_folders("aws/platform/network-account")
  mock_outputs = {
    vpc_id                                = "vpc-mock123456"
    vpc_cidr_block                        = "10.0.0.0/16"
    public_subnet_ids                     = {}
    private_subnet_ids                    = {}
    security_group_ids                    = {}
    transit_gateway_id                    = "tgw-mock123456"
    transit_gateway_route_table_id_development = "tgw-rtb-mock123456"
    transit_gateway_route_table_id_sandbox    = "tgw-rtb-mock123457"
    transit_gateway_route_table_id_production = "tgw-rtb-mock123458"
    transit_gateway_route_table_id            = "tgw-rtb-mock123459"
  }
}

# Terragrunt will use the files in this directory (main.tf, variables.tf, outputs.tf)
# The main.tf calls the workload-account module

inputs = {
  # Required variables
  account_name                    = "sre"
  vpc_cidr                        = "10.1.0.0/16"
  network_account_vpc_id          = dependency.network_account.outputs.vpc_id
  network_account_vpc_cidr        = dependency.network_account.outputs.vpc_cidr_block
  transit_gateway_id              = dependency.network_account.outputs.transit_gateway_id
  
  # SRE account connects to all environments via all route tables
  # Primary route table (development) - used by workload_account module
  transit_gateway_route_table_id = dependency.network_account.outputs.transit_gateway_route_table_id_development
  environment_type               = "development"
  
  # Additional route tables for full connectivity to all accounts
  transit_gateway_route_table_id_sandbox    = dependency.network_account.outputs.transit_gateway_route_table_id_sandbox
  transit_gateway_route_table_id_production = dependency.network_account.outputs.transit_gateway_route_table_id_production
  transit_gateway_route_table_id_network   = dependency.network_account.outputs.transit_gateway_route_table_id

  # Optional variables
  aws_region               = local.root_config.locals.aws_region
  environment              = "sre-account"
  enable_flow_logs         = true
  flow_logs_retention_days = 7

  # IaC Execution Account ID (from root.hcl)
  iac_execution_account_id = local.root_config.locals.iac_execution_account_id

  # Tags
  tags = {
    Team = "SRE"
  }
}
