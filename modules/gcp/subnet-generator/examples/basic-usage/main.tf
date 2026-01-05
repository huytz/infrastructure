# Example: Using GCP Subnet Generator Module

module "subnet_generator" {
  source = "../../"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
      region      = "us-central1"
    }
    production = {
      description = "Production Environment"
      cidr_base   = "10.1"
      region      = "us-central1"
    }
  }

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
}

# Example VPC Network (not created by module, just for reference)
variable "network_id" {
  description = "VPC network ID where subnets will be created"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

# Create subnets using generated configurations
resource "google_compute_subnetwork" "dynamic_subnets" {
  for_each = module.subnet_generator.subnets

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = var.network_id
  project       = var.project_id

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

# Output example
output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in google_compute_subnetwork.dynamic_subnets : k => v.id }
}

output "subnet_secondary_ranges" {
  description = "Secondary IP ranges by subnet"
  value = {
    for k, v in google_compute_subnetwork.dynamic_subnets : k => {
      pods     = [for r in v.secondary_ip_range : r.ip_cidr_range if contains(["pods", "pods-range"], r.range_name)]
      services = [for r in v.secondary_ip_range : r.ip_cidr_range if contains(["services", "services-range"], r.range_name)]
    }
  }
}

