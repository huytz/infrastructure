provider "google" {
  region = "us-central1"
}

resource "google_project" "huytz" {
  name            = "huytz"
  project_id      = "huytz-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
  org_id          = var.org_id
}

resource "random_id" "project_suffix" {
  byte_length = 4
}
