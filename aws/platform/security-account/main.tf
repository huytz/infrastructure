# Security Account
# Centralized security services: GuardDuty, Security Hub, Config
# Based on HashiCorp Validated Patterns for AWS Landing Zone

# Get current account ID
data "aws_caller_identity" "current" {}

# This account will be configured as the admin account for GuardDuty and Security Hub
# The actual resources are created in the management account via the security-controls module

# IAM Role for cross-account access from management account
resource "aws_iam_role" "security_admin_role" {
  name = "SecurityAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "SecurityAdminRole"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "security_admin_role" {
  role       = aws_iam_role.security_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# IAM User for console access
resource "aws_iam_user" "admin_user" {
  count = var.create_admin_user ? 1 : 0
  name  = var.admin_user_name

  tags = merge(
    var.tags,
    {
      Name      = var.admin_user_name
      ManagedBy = "Terraform"
    }
  )
}

# IAM User Login Profile (console password)
resource "aws_iam_user_login_profile" "admin_user" {
  count                   = var.create_admin_user && var.create_console_access ? 1 : 0
  user                    = aws_iam_user.admin_user[0].name
  password_reset_required = true
  password_length         = 20
}

# Attach AdministratorAccess policy to the user
resource "aws_iam_user_policy_attachment" "admin_user" {
  count      = var.create_admin_user ? 1 : 0
  user       = aws_iam_user.admin_user[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create access key for programmatic access (optional)
resource "aws_iam_access_key" "admin_user" {
  count = var.create_admin_user && var.create_access_key ? 1 : 0
  user  = aws_iam_user.admin_user[0].name
}

# Security Hub - Enable in security account
# Note: This account must be designated as admin account first (done in management account)
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}

# Security Hub Organization Configuration
# This must be managed from the admin account (this account) after admin designation
resource "aws_securityhub_organization_configuration" "main" {
  auto_enable           = true
  auto_enable_standards = "DEFAULT"

  depends_on = [aws_securityhub_account.main]
}

