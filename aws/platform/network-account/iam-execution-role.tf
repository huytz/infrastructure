# IAM Role for Organization Account Access
# This role follows AWS Organizations best practices for cross-account access
# Based on: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create-cross-account-role.html
#
# For accounts that are members of AWS Organizations, External ID is NOT required
# because the accounts are internal to your organization. This role allows the
# management/execution account to assume administrative access in this member account.
#
# Variable iac_execution_account_id is defined in variables.tf

# IAM Role that can be assumed by the management/execution account
# Using OrganizationAccountAccessRole naming convention for consistency with AWS Organizations
resource "aws_iam_role" "organization_account_access_role" {
  count = var.iac_execution_account_id != "" ? 1 : 0
  name  = var.organization_role_name

  # Trust policy allows the management/execution account to assume this role
  # No External ID required for accounts within the same AWS Organization
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.iac_execution_account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = var.organization_role_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "OrganizationAccountAccess"
    Description = "Allows management account to administer this member account"
  }
}

# Attach AWS managed AdministratorAccess policy
# This follows AWS Organizations standard practice for cross-account administration
# In production, consider creating a custom policy with least-privilege permissions
# specific to Terraform operations if full admin access is not required
resource "aws_iam_role_policy_attachment" "administrator_access" {
  count      = var.iac_execution_account_id != "" ? 1 : 0
  role       = aws_iam_role.organization_account_access_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Output the role ARN for use in management/execution account
output "organization_account_access_role_arn" {
  description = "ARN of the OrganizationAccountAccessRole for network account"
  value       = var.iac_execution_account_id != "" ? aws_iam_role.organization_account_access_role[0].arn : null
}

# Legacy output name for backward compatibility
output "terraform_execution_role_arn" {
  description = "ARN of the Terraform execution role for network account (deprecated: use organization_account_access_role_arn)"
  value       = var.iac_execution_account_id != "" ? aws_iam_role.organization_account_access_role[0].arn : null
}

