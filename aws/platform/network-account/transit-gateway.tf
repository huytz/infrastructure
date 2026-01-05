# Transit Gateway for multi-account connectivity
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for ${local.project_name} - Multi-account connectivity"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  dns_support      = "enable"
  vpn_ecmp_support = "enable"

  tags = {
    Name        = "${local.project_name}-tgw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Transit Gateway VPC Attachment for Network Account
resource "aws_ec2_transit_gateway_vpc_attachment" "network_account" {
  subnet_ids         = [for k, v in aws_subnet.private : v.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.main.id

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = {
    Name        = "${local.project_name}-tgw-attachment"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Add routes to Transit Gateway in private route tables for workload accounts
# This allows network account to reach workload accounts via Transit Gateway
# Separate routes for each environment (dev, prod) for isolation
resource "aws_route" "transit_gateway_to_workloads" {
  for_each = {
    for route in flatten([
      for env_name, env_config in var.workload_environments : [
        for rt_key, rt in aws_route_table.private : {
          key                = "${env_name}-${rt_key}"
          route_table_id     = rt.id
          destination_cidr   = env_config.vpc_cidr
          transit_gateway_id = aws_ec2_transit_gateway.main.id
        }
      ]
    ]) : route.key => route
  }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = each.value.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.network_account]
}

# Transit Gateway Route Tables for Network Isolation
# Three separate route tables: Development, Sandbox, and Production
# This ensures complete network isolation between environments
resource "aws_ec2_transit_gateway_route_table" "development" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${local.project_name}-tgw-rt-development"
    Environment = "development"
    ManagedBy   = "Terraform"
    Purpose     = "Development environment isolation"
  }
}

resource "aws_ec2_transit_gateway_route_table" "sandbox" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${local.project_name}-tgw-rt-sandbox"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
    Purpose     = "Sandbox environment isolation"
  }
}

resource "aws_ec2_transit_gateway_route_table" "production" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${local.project_name}-tgw-rt-production"
    Environment = "production"
    ManagedBy   = "Terraform"
    Purpose     = "Production environment isolation"
  }
}

# Transit Gateway Route Table for Network Account (shared)
resource "aws_ec2_transit_gateway_route_table" "network_account" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${local.project_name}-tgw-rt-network"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Network account routing"
  }
}

# Associate network account attachment with all route tables
# This allows network account to reach all environments
resource "aws_ec2_transit_gateway_route_table_association" "network_account_development" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.development.id
}

resource "aws_ec2_transit_gateway_route_table_association" "network_account_sandbox" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.sandbox.id
}

resource "aws_ec2_transit_gateway_route_table_association" "network_account_production" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

resource "aws_ec2_transit_gateway_route_table_association" "network_account" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network_account.id
}

# Propagate routes from network account to all route tables
resource "aws_ec2_transit_gateway_route_table_propagation" "network_account_development" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.development.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "network_account_sandbox" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.sandbox.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "network_account_production" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "network_account" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network_account.id
}

# Transit Gateway routes for internet traffic from workload accounts
# Each environment route table routes internet traffic to network account
resource "aws_ec2_transit_gateway_route" "internet_via_network_account_development" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.development.id
}

resource "aws_ec2_transit_gateway_route" "internet_via_network_account_sandbox" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.sandbox.id
}

resource "aws_ec2_transit_gateway_route" "internet_via_network_account_production" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.production.id
}

resource "aws_ec2_transit_gateway_route" "internet_via_network_account" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network_account.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network_account.id
}

# Note: Routes to workload VPCs are automatically propagated from workload account attachments
# Each workload account creates an attachment and associates it with the appropriate route table (development/sandbox/production)
# Route propagation automatically adds routes from workload attachments to their route tables
# The network account VPC route tables already have routes to workload VPCs via Transit Gateway (see aws_route.transit_gateway_to_workloads)


