# Create VPC network for GKE
resource "google_compute_network" "network" {
  name                    = "${local.project_name}-network"
  auto_create_subnetworks = false
  project                 = google_project.project.project_id
}

# Define environments for subnet generator
locals {
  # Define all environments
  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
      region      = var.region != "" ? var.region : "us-central1"
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
}

# Subnet Generator Module
module "subnet_generator" {
  source = "../../modules/gcp/subnet-generator"

  environments             = local.environments
  secondary_ranges         = local.secondary_ranges
  primary_subnet_cidr_size = 24
  primary_subnet_offset    = 1
}

# Create subnets dynamically for all environments and regions
resource "google_compute_subnetwork" "dynamic_subnets" {
  for_each = module.subnet_generator.subnets

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
