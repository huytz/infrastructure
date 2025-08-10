# Create Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${local.project_name}-router"
  region  = "us-central1"
  network = google_compute_network.network.id
  project = google_project.project.project_id
}

# Create Cloud NAT for private nodes to access internet
resource "google_compute_router_nat" "nat" {
  name                               = "${local.project_name}-nat"
  router                             = google_compute_router.router.name
  region                             = "us-central1"
  project                            = google_project.project.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Enable Shared VPC Host only if organization_id is provided
resource "google_compute_shared_vpc_host_project" "project" {
  count   = var.organization_id != null && var.organization_id != "" ? 1 : 0
  project = google_project.project.project_id
}
