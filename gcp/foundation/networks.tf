# Create VPC network for GKE
resource "google_compute_network" "network" {
  name                    = "${local.project_name}-network"
  auto_create_subnetworks = false
  project                 = google_project.project.project_id
}

# Define comprehensive subnet configurations for all environments and regions
locals {
  # Define all environments
  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
    }
  }

  # Define secondary IP range types
  secondary_ranges = {
    pods = {
      range_name_suffix = "pods-range"
      cidr_offset       = 1
      cidr_size         = 20
    }
    services = {
      range_name_suffix = "services-range"
      cidr_offset       = 2
      cidr_size         = 20
    }
  }

  # Generate subnet configurations dynamically with map-based secondary ranges
  subnet_configs = {
    for env_key, env_config in local.environments : env_key => {
      name          = "${env_key}-subnet"
      ip_cidr_range = "${env_config.cidr_base}.1.0/24"
      region        = "us-central1"
      environment   = env_key
      description   = env_config.description

      # Generate secondary IP ranges as a map for easier access
      # Use proper /20 boundaries: 10.0.0.0/20, 10.0.16.0/20, 10.0.32.0/20, etc.
      secondary_ranges = {
        for range_key, range_config in local.secondary_ranges : range_key => {
          range_name    = "${env_key}-${range_config.range_name_suffix}"
          ip_cidr_range = "${env_config.cidr_base}.${range_config.cidr_offset * 16}.0/${range_config.cidr_size}"
        }
      }
    }
  }

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

  # Convert to map for for_each
  subnet_map = {
    for subnet in local.flattened_subnets : subnet.key => subnet
  }
}

# Create subnets dynamically for all environments and regions
resource "google_compute_subnetwork" "dynamic_subnets" {
  for_each = local.subnet_map

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.network.id
  project       = google_project.project.project_id

  # Dynamic secondary IP ranges - convert map to list for Terraform
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  # Enable flow logs for monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
# Output network information
output "network_info" {
  description = "Network information"
  value = {
    name      = google_compute_network.network.name
    project   = google_compute_network.network.project
    self_link = google_compute_network.network.self_link
  }
}
