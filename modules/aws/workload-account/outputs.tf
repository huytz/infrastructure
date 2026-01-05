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

output "private_subnet_ids" {
  description = "Map of private subnet IDs (key: subnet key, value: subnet ID)"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_cidrs" {
  description = "Map of private subnet CIDR blocks (key: subnet key, value: CIDR)"
  value       = { for k, v in aws_subnet.private : k => v.cidr_block }
}

output "private_route_table_ids" {
  description = "Map of private route table IDs (key: subnet key, value: route table ID)"
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    default = aws_security_group.default.id
    private = aws_security_group.private.id
  }
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC Attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.workload_account.id
}

output "vpc_flow_logs_log_group" {
  description = "The CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role"
  value       = aws_iam_role.cross_account_network_access.arn
}

output "assume_role_arn" {
  description = "ARN of the IAM role for assuming roles in network account"
  value       = aws_iam_role.workload_account_assume_role.arn
}

output "organization_account_access_role_arn" {
  description = "ARN of the OrganizationAccountAccessRole for this workload account"
  value       = var.iac_execution_account_id != "" ? aws_iam_role.organization_account_access_role[0].arn : null
}

# Legacy output name for backward compatibility
output "terraform_execution_role_arn" {
  description = "ARN of the Terraform execution role for this workload account (deprecated: use organization_account_access_role_arn)"
  value       = var.iac_execution_account_id != "" ? aws_iam_role.organization_account_access_role[0].arn : null
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

# Note: No Internet Gateway or NAT Gateways in workload accounts
# Internet access is provided via Transit Gateway through network account

