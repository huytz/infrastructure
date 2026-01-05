output "organization_id" {
  description = "ID of the AWS Organization"
  value       = data.aws_organizations_organization.current.id
}

output "organization_arn" {
  description = "ARN of the AWS Organization"
  value       = data.aws_organizations_organization.current.arn
}

output "organization_master_account_id" {
  description = "ID of the master account (management account)"
  value       = data.aws_organizations_organization.current.master_account_id
}

output "organization_master_account_arn" {
  description = "ARN of the master account"
  value       = data.aws_organizations_organization.current.master_account_arn
}

output "organization_master_account_email" {
  description = "Email address of the master account"
  value       = data.aws_organizations_organization.current.master_account_email
}

output "root_id" {
  description = "ID of the root organizational unit"
  value       = data.aws_organizations_organization.current.roots[0].id
}

output "platform_ou_id" {
  description = "ID of the Platform OU"
  value       = aws_organizations_organizational_unit.platform.id
}

output "workloads_ou_id" {
  description = "ID of the Workloads OU"
  value       = aws_organizations_organizational_unit.workloads.id
}

output "workload_ou_ids" {
  description = "Map of workload environment names to OU IDs"
  value = {
    for k, v in aws_organizations_organizational_unit.workload_sub_ous : k => v.id
  }
}

output "all_ou_ids" {
  description = "Map of all OU names to their IDs"
  value = {
    platform  = aws_organizations_organizational_unit.platform.id
    workloads = aws_organizations_organizational_unit.workloads.id
    dev       = aws_organizations_organizational_unit.workload_sub_ous["dev"].id
    sandbox   = aws_organizations_organizational_unit.workload_sub_ous["sandbox"].id
    prod      = aws_organizations_organizational_unit.workload_sub_ous["prod"].id
  }
}

output "created_accounts" {
  description = "Map of created account names to their account IDs"
  value = {
    for k, v in aws_organizations_account.accounts : k => {
      id    = v.id
      arn   = v.arn
      email = v.email
      name  = v.name
    }
  }
}

