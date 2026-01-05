output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "public_subnet_cidrs" {
  description = "Map of public subnet CIDR blocks"
  value       = { for k, v in aws_subnet.public : k => v.cidr_block }
}

output "private_subnet_cidrs" {
  description = "Map of private subnet CIDR blocks"
  value       = { for k, v in aws_subnet.private : k => v.cidr_block }
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = { for k, v in aws_nat_gateway.main : k => v.id }
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = { for k, v in aws_nat_gateway.main : k => v.public_ip }
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of private route table IDs"
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    default = aws_security_group.default.id
    public  = aws_security_group.public.id
    private = aws_security_group.private.id
  }
}

output "vpc_flow_logs_log_group" {
  description = "The CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

# Subnet configurations grouped by environment
output "subnet_configurations" {
  description = "Subnet configurations grouped by environment"
  value = {
    for env_key, env_config in local.subnet_configs : env_key => {
      public_subnets = {
        for az, subnet in env_config.public_subnets : az => {
          name              = subnet.name
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          subnet_id         = aws_subnet.public["${env_key}-${az}"].id
        }
      }
      private_subnets = {
        for az, subnet in env_config.private_subnets : az => {
          name              = subnet.name
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
          subnet_id         = aws_subnet.private["${env_key}-${az}"].id
        }
      }
    }
  }
}

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC Attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.network_account.id
}

output "transit_gateway_route_table_id" {
  description = "The ID of the Transit Gateway Route Table (network account)"
  value       = aws_ec2_transit_gateway_route_table.network_account.id
}

output "transit_gateway_route_table_id_development" {
  description = "The ID of the Transit Gateway Route Table for development environment"
  value       = aws_ec2_transit_gateway_route_table.development.id
}

output "transit_gateway_route_table_id_sandbox" {
  description = "The ID of the Transit Gateway Route Table for sandbox environment"
  value       = aws_ec2_transit_gateway_route_table.sandbox.id
}

output "transit_gateway_route_table_id_production" {
  description = "The ID of the Transit Gateway Route Table for production environment"
  value       = aws_ec2_transit_gateway_route_table.production.id
}

output "transit_gateway_route_table_ids" {
  description = "Map of Transit Gateway Route Table IDs by environment"
  value = {
    network     = aws_ec2_transit_gateway_route_table.network_account.id
    development = aws_ec2_transit_gateway_route_table.development.id
    sandbox     = aws_ec2_transit_gateway_route_table.sandbox.id
    production  = aws_ec2_transit_gateway_route_table.production.id
  }
}

output "private_hosted_zone_id" {
  description = "The ID of the private Route53 hosted zone"
  value       = aws_route53_zone.private.zone_id
}

output "private_hosted_zone_name" {
  description = "The name of the private Route53 hosted zone"
  value       = aws_route53_zone.private.name
}

output "private_hosted_zone_name_servers" {
  description = "The name servers for the private Route53 hosted zone"
  value       = aws_route53_zone.private.name_servers
}

