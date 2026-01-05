# Outputs from production team
output "production_project_id" {
  description = "The ID of the production team project"
  value       = module.production_team.project_id
}

output "production_project_name" {
  description = "The name of the production team project"
  value       = module.production_team.project_name
}

# Outputs from staging team
output "staging_project_id" {
  description = "The ID of the staging team project"
  value       = module.staging_team.project_id
}

output "staging_project_name" {
  description = "The name of the staging team project"
  value       = module.staging_team.project_name
}

