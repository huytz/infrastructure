locals {
  project_name = basename(path.cwd)
}

# Create the Foundation Project
resource "google_project" "project" {
  name            = local.project_name
  project_id      = "${local.project_name}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
  org_id          = var.organization_id
}

resource "random_id" "project_suffix" {
  byte_length = 4
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ])

  project = google_project.project.project_id
  service = each.value
}
