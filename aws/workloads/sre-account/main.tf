# SRE Account using the workload-account module
# This wrapper allows us to customize outputs and add account-specific resources
# SRE account needs to connect to all accounts, so we attach to all Transit Gateway route tables
# The workload_account module handles the primary attachment to development route table
# We add additional associations and propagations for sandbox, production, and network route tables

module "workload_account" {
  source = "../../modules/aws/workload-account"

  # Required variables
  account_name                    = var.account_name
  vpc_cidr                        = var.vpc_cidr
  network_account_vpc_id          = var.network_account_vpc_id
  network_account_vpc_cidr       = var.network_account_vpc_cidr
  transit_gateway_id              = var.transit_gateway_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  environment_type               = var.environment_type

  # Optional variables
  aws_region               = var.aws_region
  environment              = var.environment
  enable_dns_hostnames     = var.enable_dns_hostnames
  enable_dns_support       = var.enable_dns_support
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days
  subnet_count             = var.subnet_count
  subnet_cidr_offset       = var.subnet_cidr_offset
  iac_execution_account_id  = var.iac_execution_account_id
  tags                      = var.tags
}

# Additional Transit Gateway Route Table Associations
# SRE account needs to connect to all environments (development, sandbox, production, network)
# The workload_account module already associates with development route table
# We add associations for the remaining route tables

resource "aws_ec2_transit_gateway_route_table_association" "sre_sandbox" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_sandbox
}

resource "aws_ec2_transit_gateway_route_table_association" "sre_production" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_production
}

resource "aws_ec2_transit_gateway_route_table_association" "sre_network" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_network
}

# Route Propagations for all route tables
# This allows SRE account routes to be propagated to all environments

resource "aws_ec2_transit_gateway_route_table_propagation" "sre_sandbox" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_sandbox
}

resource "aws_ec2_transit_gateway_route_table_propagation" "sre_production" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_production
}

resource "aws_ec2_transit_gateway_route_table_propagation" "sre_network" {
  transit_gateway_attachment_id  = module.workload_account.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id_network
}

