output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.gke_network.name
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.gke_network.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "pods_ip_range" {
  description = "The IP range for GKE pods"
  value       = "pods"
}

output "services_ip_range" {
  description = "The IP range for GKE services"
  value       = "services"
} 