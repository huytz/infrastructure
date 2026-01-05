locals {
  environment = var.environment != "" ? var.environment : var.account_name
  
  # Extract CIDR base from VPC CIDR (e.g., "10.1.0.0/16" -> "10.1")
  vpc_cidr_parts = split(".", split("/", var.vpc_cidr)[0])
  cidr_base      = "${vpc_cidr_parts[0]}.${vpc_cidr_parts[1]}"
  
  # Define environment for subnet generator (workload accounts only have private subnets)
  environments = {
    (var.account_name) = {
      description = "${var.account_name} Workload Account"
      cidr_base   = local.cidr_base
    }
  }
  
  # Common tags
  common_tags = merge(
    {
      Name        = var.account_name
      Environment = local.environment
      ManagedBy   = "Terraform"
      Module      = "workload-account"
    },
    var.tags
  )
}

# Subnet Generator Module (only generates private subnets for workload accounts)
module "subnet_generator" {
  source = "../subnet-generator"

  environments = local.environments
  aws_region   = var.aws_region
  
  # Workload accounts only use private subnets
  public_subnet_offset  = 1   # Not used, but required
  private_subnet_offset = var.subnet_cidr_offset
  subnet_cidr_size      = 24
  max_azs              = var.subnet_count
}

# Use module outputs
locals {
  azs = module.subnet_generator.availability_zones
}

