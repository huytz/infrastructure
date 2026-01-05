# Centralized Cloud DNS Private Zone for Foundation Project
# This DNS zone is shared with all service projects via Shared VPC
# Following GCP Landing Zone best practices for centralized DNS management

resource "google_dns_managed_zone" "private" {
  name        = var.dns_zone_name != "" ? var.dns_zone_name : "foundation-internal"
  dns_name    = var.dns_domain_name != "" ? var.dns_domain_name : "foundation.internal."
  description = "Centralized private DNS zone for foundation project - shared with all service projects"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.network.id
    }
  }

  project = google_project.project.project_id

  depends_on = [
    google_project_service.apis,
    google_compute_network.network
  ]
}

# Optional: Add initial DNS records (e.g., for common services)
resource "google_dns_record_set" "initial_records" {
  for_each = var.initial_dns_records

  managed_zone = google_dns_managed_zone.private.name
  name         = "${each.value.name}.${google_dns_managed_zone.private.dns_name}"
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas

  project = google_project.project.project_id
}

