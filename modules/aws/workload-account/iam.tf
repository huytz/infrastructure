# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Role for cross-account access (for network account to access workload resources)
resource "aws_iam_role" "cross_account_network_access" {
  name = "${var.account_name}-cross-account-network-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "${var.account_name}-network-account"
          }
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.account_name}-cross-account-network-role"
    },
    local.common_tags
  )
}

# Policy for cross-account VPC access
resource "aws_iam_role_policy" "cross_account_vpc_access" {
  name = "${var.account_name}-cross-account-vpc-policy"
  role = aws_iam_role.cross_account_network_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayRouteTables"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for workload account to assume in network account
resource "aws_iam_role" "workload_account_assume_role" {
  name = "${var.account_name}-assume-network-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.account_name}-assume-network-role"
    },
    local.common_tags
  )
}

# IAM Role for Organization Account Access
# This role follows AWS Organizations best practices for cross-account access
# Based on: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create-cross-account-role.html
#
# For accounts that are members of AWS Organizations, External ID is NOT required
# because the accounts are internal to your organization. This role allows the
# management/execution account to assume administrative access in this member account.
resource "aws_iam_role" "organization_account_access_role" {
  count = var.iac_execution_account_id != "" ? 1 : 0
  name  = "OrganizationAccountAccessRole"

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
        # Note: External ID is NOT used for accounts within AWS Organizations
        # as per AWS best practices for internal accounts
      }
    ]
  })

  tags = merge(
    {
      Name        = "OrganizationAccountAccessRole"
      Purpose     = "OrganizationAccountAccess"
      Description = "Allows management account to administer this member account"
    },
    local.common_tags
  )
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

