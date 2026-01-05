output "project_id" {
  description = "The ID of the created project"
  value       = google_project.project.project_id
}

output "project_name" {
  description = "The name of the created project"
  value       = google_project.project.name
}

output "project_number" {
  description = "The project number"
  value       = google_project.project.number
}

output "service_project_attachment_id" {
  description = "The ID of the Shared VPC service project attachment (if enabled)"
  value       = var.enable_shared_vpc ? google_compute_shared_vpc_service_project.service_project_attach[0].id : null
}

output "enabled_apis" {
  description = "List of enabled API service names"
  value       = [for api in google_project_service.apis : api.service]
}

