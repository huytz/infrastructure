# List of required Google APIs
locals {
  required_apis = [
    "container.googleapis.com",            # Kubernetes Engine API
    "compute.googleapis.com",              # Compute Engine API
    "iam.googleapis.com",                  # Identity and Access Management API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "servicenetworking.googleapis.com",    # Service Networking API
    "dns.googleapis.com",                  # Cloud DNS API
    "logging.googleapis.com",              # Cloud Logging API
    "monitoring.googleapis.com",           # Cloud Monitoring API
    "artifactregistry.googleapis.com"      # Artifact Registry API
  ]
}

# Enable required Google APIs using for_each loop
resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project = google_project.huytz.project_id
  service = each.value
}
