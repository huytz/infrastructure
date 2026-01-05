# AWS IAM Identity Center (formerly AWS SSO)
# Provides centralized access management via awsapps.com URL
# Based on AWS Landing Zone best practices
#
# Note: IAM Identity Center is automatically enabled when first accessed via AWS Console
# This configuration assumes it has been enabled. If not, enable it via:
# AWS Console -> IAM Identity Center -> Enable

# Get the Identity Center instance (must be enabled first via Console)
data "aws_ssoadmin_instances" "main" {
  count = var.enable_identity_center ? 1 : 0
}

locals {
  identity_center_instance_arn = var.enable_identity_center && length(data.aws_ssoadmin_instances.main) > 0 && length(data.aws_ssoadmin_instances.main[0].arns) > 0 ? tolist(data.aws_ssoadmin_instances.main[0].arns)[0] : ""
  identity_center_instance_id  = var.enable_identity_center && length(data.aws_ssoadmin_instances.main) > 0 && length(data.aws_ssoadmin_instances.main[0].identity_store_ids) > 0 ? tolist(data.aws_ssoadmin_instances.main[0].identity_store_ids)[0] : ""
}

# Permission Set: AdministratorAccess
resource "aws_ssoadmin_permission_set" "administrator_access" {
  count            = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  name             = "AdministratorAccess"
  description      = "Full access to AWS services and resources"
  instance_arn     = local.identity_center_instance_arn
  session_duration = "PT1H" # 1 hour

  tags = merge(
    var.tags,
    {
      Name      = "AdministratorAccess"
      ManagedBy = "Terraform"
    }
  )
}

# Attach AWS managed policy: AdministratorAccess
resource "aws_ssoadmin_managed_policy_attachment" "administrator_access" {
  count              = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  instance_arn       = local.identity_center_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access[0].arn
}

# Permission Set: ReadOnlyAccess
resource "aws_ssoadmin_permission_set" "readonly_access" {
  count            = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  name             = "ReadOnlyAccess"
  description      = "Read-only access to AWS services and resources"
  instance_arn     = local.identity_center_instance_arn
  session_duration = "PT1H"

  tags = merge(
    var.tags,
    {
      Name      = "ReadOnlyAccess"
      ManagedBy = "Terraform"
    }
  )
}

# Attach AWS managed policy: ReadOnlyAccess
resource "aws_ssoadmin_managed_policy_attachment" "readonly_access" {
  count              = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  instance_arn       = local.identity_center_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly_access[0].arn
}

# Permission Set: SecurityAudit
resource "aws_ssoadmin_permission_set" "security_audit" {
  count            = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  name             = "SecurityAudit"
  description      = "Security audit access to AWS services and resources"
  instance_arn     = local.identity_center_instance_arn
  session_duration = "PT1H"

  tags = merge(
    var.tags,
    {
      Name      = "SecurityAudit"
      ManagedBy = "Terraform"
    }
  )
}

# Attach AWS managed policy: SecurityAudit
resource "aws_ssoadmin_managed_policy_attachment" "security_audit" {
  count              = var.enable_identity_center && local.identity_center_instance_arn != "" ? 1 : 0
  instance_arn       = local.identity_center_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
  permission_set_arn = aws_ssoadmin_permission_set.security_audit[0].arn
}

