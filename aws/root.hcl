# AWS Root Configuration
locals {
  environment = try(basename(path_relative_to_include()), "default")
  aws_region  = get_env("AWS_REGION", "us-east-1")

  # Organization & Account IDs
  organization_name    = "MyOrganization"
  current_account_id   = "759369181357"
  management_account_id = "759369181357"
  iac_execution_account_id = local.management_account_id
  
  # Bucket names
  cloudtrail_log_bucket_name = "${local.organization_name}-cloudtrail-log"
  config_log_bucket_name     = "${local.organization_name}-config-log"
  terraform_state_bucket_name = "${local.management_account_id}-state"

  # Provider config
  aws_provider = <<-EOF
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = basename(path.cwd)
    }
  }
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0.0" }
    random = { source = "hashicorp/random", version = "~> 3.1.0" }
    null   = { source = "hashicorp/null", version = "~> 3.2.0" }
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.aws_provider
}

remote_state {
  backend = "s3"
  config = {
    bucket  = local.terraform_state_bucket_name
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
