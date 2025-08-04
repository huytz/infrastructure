# Create Cloud Router for NAT
resource "google_compute_router" "gke_router" {
  name    = "router"
  region  = "us-central1"
  network = google_compute_network.gke_network.id
  project = var.project_id
}

# Create Cloud NAT for private nodes to access internet
resource "google_compute_router_nat" "gke_nat" {
  name                               = "nat"
  router                             = google_compute_router.gke_router.name
  region                             = "us-central1"
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
