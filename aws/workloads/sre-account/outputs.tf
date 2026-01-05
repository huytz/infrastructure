# Outputs from the workload-account module
# These outputs are passed through from the module

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.workload_account.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.workload_account.vpc_cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.workload_account.vpc_arn
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.workload_account.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.workload_account.private_subnet_cidrs
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.workload_account.private_route_table_ids
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = module.workload_account.security_group_ids
}

output "transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway VPC Attachment"
  value       = module.workload_account.transit_gateway_attachment_id
}

output "vpc_flow_logs_log_group" {
  description = "The CloudWatch Log Group for VPC Flow Logs"
  value       = module.workload_account.vpc_flow_logs_log_group
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role"
  value       = module.workload_account.cross_account_role_arn
}

output "assume_role_arn" {
  description = "ARN of the IAM role for assuming roles in network account"
  value       = module.workload_account.assume_role_arn
}
