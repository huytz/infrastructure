# Use existing AWS Organization (assumes organization already exists)
data "aws_organizations_organization" "current" {}

# Create top-level Organizational Units
resource "aws_organizations_organizational_unit" "platform" {
  name      = var.organizational_units["platform"].name
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name = var.organizational_units["platform"].name

    Environment = var.environment
    ManagedBy   = "Terraform"
    Type        = "Platform"
  }
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = var.organizational_units["workloads"].name
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = {
    Name = var.organizational_units["workloads"].name

    Environment = var.environment
    ManagedBy   = "Terraform"
    Type        = "Workload"
  }
}

# Create sub-OUs under Workloads OU
resource "aws_organizations_organizational_unit" "workload_sub_ous" {
  for_each = var.workload_ous

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = {
    Name = each.value.name

    Environment = each.value.name
    ManagedBy   = "Terraform"
    Type        = "Workload"
  }
}


# Local values to map OU paths to OU IDs
locals {
  ou_id_map = {
    platform            = aws_organizations_organizational_unit.platform.id
    workloads           = aws_organizations_organizational_unit.workloads.id
    "workloads/dev"     = aws_organizations_organizational_unit.workload_sub_ous["dev"].id
    "workloads/sandbox" = aws_organizations_organizational_unit.workload_sub_ous["sandbox"].id
    "workloads/prod"    = aws_organizations_organizational_unit.workload_sub_ous["prod"].id
  }
}

# Create new AWS accounts in the organization
resource "aws_organizations_account" "accounts" {
  for_each = var.enable_account_creation ? {
    for account_name, ou_path in var.account_ou_mapping :
    account_name => ou_path
    if var.account_ou_mapping[account_name] != ""
  } : {}

  name  = title(each.key)
  email = var.account_email_domain != "" ? "aws-${each.key}@${var.account_email_domain}" : "aws-${each.key}@${var.organization_name}.com"

  # Determine parent OU ID based on path
  parent_id = local.ou_id_map[each.value]

  tags = {
    Name        = title(each.key)
    Environment = var.environment
    ManagedBy   = "Terraform"
    Type        = try(split("/", each.value)[0], each.value)
  }

  depends_on = [
    data.aws_organizations_organization.current,
    aws_organizations_organizational_unit.platform,
    aws_organizations_organizational_unit.workloads,
    aws_organizations_organizational_unit.workload_sub_ous,
  ]
}

