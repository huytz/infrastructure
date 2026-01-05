locals {
  # ============================================================================
  # Helper Functions (as locals)
  # ============================================================================
  # Generate primary subnet CIDR blocks
  primary_subnet_cidrs = {
    for env_key, env_config in var.environments : env_key => "${env_config.cidr_base}.${var.primary_subnet_offset}.0/${var.primary_subnet_cidr_size}"
  }

  # Generate subnet names
  subnet_names = {
    for env_key, env_config in var.environments : env_key => "${env_key}-subnet"
  }

  # Generate secondary IP ranges for each environment
  # Use proper /20 boundaries: 10.0.0.0/20, 10.0.16.0/20, 10.0.32.0/20, etc.
  secondary_ranges_by_env = {
    for env_key, env_config in var.environments : env_key => {
      for range_key, range_config in var.secondary_ranges : range_key => {
        range_name    = "${env_key}-${range_config.range_name_suffix}"
        ip_cidr_range = "${env_config.cidr_base}.${range_config.cidr_offset * 16}.0/${range_config.cidr_size}"
      }
    }
  }

  # ============================================================================
  # Subnet Configurations
  # ============================================================================
  # Generate complete subnet configurations by environment
  subnet_configs = {
    for env_key, env_config in var.environments : env_key => {
      name          = local.subnet_names[env_key]
      ip_cidr_range = local.primary_subnet_cidrs[env_key]
      region        = env_config.region
      environment   = env_key
      description   = env_config.description

      # Secondary IP ranges (for GKE pods and services)
      secondary_ranges = local.secondary_ranges_by_env[env_key]
    }
  }

  # ============================================================================
  # Flattened Subnet Maps (for for_each usage)
  # ============================================================================
  # Flatten subnet configurations for easier iteration
  flattened_subnets = [
    for env_key, subnet_config in local.subnet_configs : {
      key              = env_key
      name             = subnet_config.name
      ip_cidr_range    = subnet_config.ip_cidr_range
      region           = subnet_config.region
      environment      = subnet_config.environment
      description      = subnet_config.description
      secondary_ranges = subnet_config.secondary_ranges
    }
  ]

  # Convert to map for for_each (ready to use in resources)
  subnet_map = {
    for subnet in local.flattened_subnets : subnet.key => subnet
  }
}

