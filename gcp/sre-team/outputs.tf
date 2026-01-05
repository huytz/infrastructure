# Outputs from workload-project module
output "project_id" {
  description = "The ID of the created project"
  value       = module.workload_project.project_id
}

output "project_name" {
  description = "The name of the created project"
  value       = module.workload_project.project_name
}

output "project" {
  description = "The name of the created project (alias for project_name)"
  value       = module.workload_project.project_name
}

output "project_number" {
  description = "The project number"
  value       = module.workload_project.project_number
}

output "service_project_attachment_id" {
  description = "The ID of the Shared VPC service project attachment"
  value       = module.workload_project.service_project_attachment_id
}

output "enabled_apis" {
  description = "List of enabled API service names"
  value       = module.workload_project.enabled_apis
}
