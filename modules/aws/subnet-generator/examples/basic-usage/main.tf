# Example: Using AWS Subnet Generator Module

module "subnet_generator" {
  source = "../../"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
    }
    production = {
      description = "Production Environment"
      cidr_base   = "10.1"
    }
  }

  aws_region = "us-east-1"
}

# Example VPC (not created by module, just for reference)
variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

# Create public subnets using generated configurations
resource "aws_subnet" "public" {
  for_each = module.subnet_generator.public_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = each.value.name
    Type        = "public"
    Environment = each.value.env
  }
}

# Create private subnets using generated configurations
resource "aws_subnet" "private" {
  for_each = module.subnet_generator.private_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = each.value.name
    Type        = "private"
    Environment = each.value.env
  }
}

# Output example
output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

