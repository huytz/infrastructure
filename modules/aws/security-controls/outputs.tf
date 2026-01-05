output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.organization_trail[0].arn : null
}

output "cloudtrail_id" {
  description = "ID of the CloudTrail trail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.organization_trail[0].id : null
}

