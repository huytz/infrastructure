output "project_id" {
  value = google_project.project.project_id
}

output "project" {
  value = google_project.project.name
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.network.name
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.network.id
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.network.self_link
}

# Dynamic subnet outputs for all environments
output "subnet_names" {
  description = "The names of all subnets"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => subnet.name
  }
}

output "subnet_ids" {
  description = "The IDs of all subnets"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => subnet.id
  }
}

output "subnet_self_links" {
  description = "The self-links of all subnets"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => subnet.self_link
  }
}

output "subnet_ip_cidr_ranges" {
  description = "The IP CIDR ranges of all subnets"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => subnet.ip_cidr_range
  }
}

output "subnet_secondary_ranges" {
  description = "The secondary IP ranges of all subnets"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => subnet.secondary_ip_range
  }
}

# Create a flattened subnet configuration with map-based secondary ranges for all environments
output "subnet_configurations" {
  description = "Subnet configurations with flattened map-based secondary ranges for all environments"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => {
      name          = subnet.name
      ip_cidr_range = subnet.ip_cidr_range
      region        = subnet.region
      self_link     = subnet.self_link
      # Convert secondary ranges list to map for easier access
      secondary_ranges = {
        for range in subnet.secondary_ip_range : range.range_name => {
          range_name    = range.range_name
          ip_cidr_range = range.ip_cidr_range
        }
      }
    }
  }
}
