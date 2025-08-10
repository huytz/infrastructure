locals {
  # Get project name from directory structure
  project_name = basename(path.cwd)
}
resource "google_project" "project" {
  name            = local.project_name
  project_id      = "${local.project_name}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
  org_id          = var.organization_id
}

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

  project = google_project.project.project_id
  service = each.value
}

resource "random_id" "project_suffix" {
  byte_length = 4
}


resource "google_compute_shared_vpc_service_project" "service_project_attach" {
  host_project    = var.foundation_project_id
  service_project = google_project.project.project_id
}
