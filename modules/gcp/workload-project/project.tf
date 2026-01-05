locals {
  # Common tags/labels
  common_labels = merge(
    {
      managed_by = "terraform"
      team       = var.team_name
    },
    var.tags
  )
}

# Create the Workload Team Project
resource "google_project" "project" {
  name            = var.team_name
  project_id      = "${var.team_name}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
  org_id          = var.organization_id

  labels = local.common_labels
}

# Random suffix for project ID uniqueness
resource "random_id" "project_suffix" {
  byte_length = var.project_suffix_length
}

# Enable required Google APIs
resource "google_project_service" "apis" {
  for_each = toset(var.required_apis)

  project = google_project.project.project_id
  service = each.value

  disable_on_destroy = false
}

# Attach to foundation project as Shared VPC service project
resource "google_compute_shared_vpc_service_project" "service_project_attach" {
  count = var.enable_shared_vpc ? 1 : 0

  host_project    = var.foundation_project_id
  service_project = google_project.project.project_id

  depends_on = [
    google_project_service.apis
  ]
}

