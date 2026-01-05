output "subnet_configs" {
  description = "Complete subnet configurations by environment"
  value       = local.subnet_configs
}

output "public_subnets" {
  description = "Flattened map of public subnets ready for for_each"
  value       = local.public_subnets_flat
}

output "private_subnets" {
  description = "Flattened map of private subnets ready for for_each"
  value       = local.private_subnets_flat
}

output "subnet_to_env" {
  description = "Map of subnet keys to environment names (useful for NAT Gateway EIP lookup)"
  value       = local.subnet_to_env
}

output "availability_zones" {
  description = "List of availability zones for the current region"
  value       = local.azs
}

output "public_subnet_configs" {
  description = "Public subnet configurations by environment"
  value = {
    for env_key, env_config in local.subnet_configs : env_key => env_config.public_subnets
  }
}

output "private_subnet_configs" {
  description = "Private subnet configurations by environment"
  value = {
    for env_key, env_config in local.subnet_configs : env_key => env_config.private_subnets
  }
}

