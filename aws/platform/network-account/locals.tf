locals {
  project_name = basename(path.cwd)

  # Define all environments
  environments = {
    sre-account = {
      description = "SRE Account Environment"
      cidr_base   = "10.0"
    }
  }
}

# Subnet Generator Module
module "subnet_generator" {
  source = "../../../modules/aws/subnet-generator"

  environments = local.environments
  aws_region   = var.aws_region
}

# Use module outputs for subnet configurations
locals {
  subnet_configs = module.subnet_generator.subnet_configs
  subnet_to_env  = module.subnet_generator.subnet_to_env
  azs            = module.subnet_generator.availability_zones
}

