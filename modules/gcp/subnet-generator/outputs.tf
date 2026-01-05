output "subnet_configs" {
  description = "Complete subnet configurations by environment"
  value       = local.subnet_configs
}

output "subnets" {
  description = "Flattened map of subnets ready for for_each"
  value       = local.subnet_map
}

output "flattened_subnets" {
  description = "List of flattened subnet configurations"
  value       = local.flattened_subnets
}

output "subnet_configs_by_region" {
  description = "Subnet configurations grouped by region"
  value = {
    for env_key, subnet_config in local.subnet_configs : env_key => {
      region        = subnet_config.region
      ip_cidr_range = subnet_config.ip_cidr_range
      name          = subnet_config.name
    }
  }
}

output "secondary_ranges_by_environment" {
  description = "Secondary IP ranges grouped by environment"
  value = {
    for env_key, subnet_config in local.subnet_configs : env_key => subnet_config.secondary_ranges
  }
}

