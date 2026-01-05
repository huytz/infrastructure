locals {
  # ============================================================================
  # Availability Zones
  # ============================================================================
  # Get availability zones for current region with fallback to auto-generated AZs
  azs = try(
    var.availability_zones[var.aws_region],
    ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  )

  # Limit AZs to max_azs for subnet generation
  azs_for_subnets = slice(local.azs, 0, min(var.max_azs, length(local.azs)))

  # ============================================================================
  # Helper Functions (as locals)
  # ============================================================================
  # Generate subnet CIDR block
  subnet_cidr = {
    for env_key, env_config in var.environments : env_key => {
      public  = { for idx, az in local.azs_for_subnets : az => "${env_config.cidr_base}.${var.public_subnet_offset + idx}.0/${var.subnet_cidr_size}" }
      private = { for idx, az in local.azs_for_subnets : az => "${env_config.cidr_base}.${var.private_subnet_offset + idx}.0/${var.subnet_cidr_size}" }
    }
  }

  # Generate subnet names
  subnet_names = {
    for env_key, env_config in var.environments : env_key => {
      public  = { for az in local.azs_for_subnets : az => "${env_key}-public-${substr(az, -1, 1)}" }
      private = { for az in local.azs_for_subnets : az => "${env_key}-private-${substr(az, -1, 1)}" }
    }
  }

  # ============================================================================
  # Subnet Configurations
  # ============================================================================
  # Generate complete subnet configurations by environment
  subnet_configs = {
    for env_key, env_config in var.environments : env_key => {
      name          = "${env_key}-subnet"
      cidr_base     = env_config.cidr_base
      description   = env_config.description
      environment   = env_key

      # Public subnets (one per AZ)
      public_subnets = {
        for az in local.azs_for_subnets : az => {
          name              = local.subnet_names[env_key].public[az]
          cidr_block        = local.subnet_cidr[env_key].public[az]
          availability_zone = az
        }
      }

      # Private subnets (one per AZ)
      private_subnets = {
        for az in local.azs_for_subnets : az => {
          name              = local.subnet_names[env_key].private[az]
          cidr_block        = local.subnet_cidr[env_key].private[az]
          availability_zone = az
        }
      }
    }
  }

  # ============================================================================
  # Flattened Subnet Maps (for for_each usage)
  # ============================================================================
  # Helper function: Flatten subnets by type
  flatten_subnets_by_type = {
    public = flatten([
      for env_key, env_config in local.subnet_configs : [
        for az, subnet in env_config.public_subnets : {
          key  = "${env_key}-${az}"
          env  = env_key
          az   = az
          name = subnet.name
          cidr = subnet.cidr_block
        }
      ]
    ])
    private = flatten([
      for env_key, env_config in local.subnet_configs : [
        for az, subnet in env_config.private_subnets : {
          key  = "${env_key}-${az}"
          env  = env_key
          az   = az
          name = subnet.name
          cidr = subnet.cidr_block
        }
      ]
    ])
  }

  # Flattened public subnets (ready for for_each)
  public_subnets_flat = {
    for subnet in local.flatten_subnets_by_type.public : subnet.key => subnet
  }

  # Flattened private subnets (ready for for_each)
  private_subnets_flat = {
    for subnet in local.flatten_subnets_by_type.private : subnet.key => subnet
  }

  # ============================================================================
  # Subnet Mapping (for NAT Gateway EIP lookup)
  # ============================================================================
  # Map subnet keys to environment names (useful for NAT Gateway EIP lookup)
  subnet_to_env = {
    for k, v in local.public_subnets_flat : k => v.env
  }
}

