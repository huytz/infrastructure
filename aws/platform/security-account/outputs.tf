output "security_admin_role_arn" {
  description = "ARN of the Security Admin role"
  value       = aws_iam_role.security_admin_role.arn
}

output "admin_user_name" {
  description = "Name of the admin IAM user"
  value       = var.create_admin_user ? aws_iam_user.admin_user[0].name : null
}

output "admin_user_arn" {
  description = "ARN of the admin IAM user"
  value       = var.create_admin_user ? aws_iam_user.admin_user[0].arn : null
}

output "admin_user_password" {
  description = "Initial password for the admin user (only shown once)"
  value       = var.create_admin_user && var.create_console_access ? aws_iam_user_login_profile.admin_user[0].password : null
  sensitive   = true
}

output "admin_user_access_key_id" {
  description = "Access key ID for the admin user (if created)"
  value       = var.create_admin_user && var.create_access_key ? aws_iam_access_key.admin_user[0].id : null
}

output "admin_user_secret_access_key" {
  description = "Secret access key for the admin user (if created) - only shown once"
  value       = var.create_admin_user && var.create_access_key ? aws_iam_access_key.admin_user[0].secret : null
  sensitive   = true
}

output "security_account_id" {
  description = "Security account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "securityhub_account_id" {
  description = "Security Hub account ID"
  value       = aws_securityhub_account.main.id
}

