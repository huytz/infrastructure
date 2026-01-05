output "organization_id" {
  description = "AWS Organization ID"
  value       = data.aws_organizations_organization.current.id
}

output "organization_root_id" {
  description = "AWS Organization Root ID"
  value       = data.aws_organizations_organization.current.roots[0].id
}

output "management_account_id" {
  description = "Management account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "scp_ids" {
  description = "Service Control Policy IDs"
  value       = var.enable_scps ? module.scps[0].scp_ids : {}
}

output "security_controls" {
  description = "Security controls outputs"
  value = var.enable_security_controls ? {
    cloudtrail_arn = module.security_controls[0].cloudtrail_arn
    cloudtrail_id  = module.security_controls[0].cloudtrail_id
  } : {}
}

output "identity_center_instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  value       = var.enable_identity_center ? local.identity_center_instance_arn : null
}

output "identity_center_instance_id" {
  description = "ID of the IAM Identity Center instance (for awsapps.com URL)"
  value       = var.enable_identity_center ? local.identity_center_instance_id : null
}

output "identity_center_portal_url" {
  description = "IAM Identity Center portal URL (awsapps.com)"
  value       = var.enable_identity_center && local.identity_center_instance_id != "" ? "https://${local.identity_center_instance_id}.awsapps.com" : null
}

output "identity_center_permission_sets" {
  description = "IAM Identity Center permission set ARNs"
  value = var.enable_identity_center && local.identity_center_instance_arn != "" ? {
    administrator_access = length(aws_ssoadmin_permission_set.administrator_access) > 0 ? aws_ssoadmin_permission_set.administrator_access[0].arn : null
    readonly_access      = length(aws_ssoadmin_permission_set.readonly_access) > 0 ? aws_ssoadmin_permission_set.readonly_access[0].arn : null
    security_audit       = length(aws_ssoadmin_permission_set.security_audit) > 0 ? aws_ssoadmin_permission_set.security_audit[0].arn : null
  } : {}
}

