# Management Account Configuration
# Based on HashiCorp Validated Patterns: https://developer.hashicorp.com/validated-patterns/terraform/build-aws-lz-with-terraform
# This is the central control plane for the AWS Landing Zone

# Get current account ID (management account)
data "aws_caller_identity" "current" {}

# Get organization details
data "aws_organizations_organization" "current" {}

# Deploy Service Control Policies
module "scps" {
  source = "../../../modules/aws/scps"

  organization_root_id = data.aws_organizations_organization.current.roots[0].id

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  count = var.enable_scps ? 1 : 0
}

# Deploy Security Controls (CloudTrail)
module "security_controls" {
  source = "../../../modules/aws/security-controls"

  cloudtrail_log_bucket_name = var.cloudtrail_log_bucket_name
  enable_cloudtrail          = var.enable_security_controls

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  count = var.enable_security_controls ? 1 : 0
}

