# Security Controls Module
# Based on HashiCorp Validated Patterns for AWS Landing Zone
# Implements centralized security services: CloudTrail

# CloudTrail - Organization-wide trail
resource "aws_cloudtrail" "organization_trail" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "organization-trail"
  s3_bucket_name                = var.cloudtrail_log_bucket_name != "" ? var.cloudtrail_log_bucket_name : null
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type                 = "All"
    include_management_events        = true
    exclude_management_event_sources = []
  }

  tags = merge(
    var.tags,
    {
      Name        = "organization-trail"
      Service     = "CloudTrail"
      ManagedBy    = "Terraform"
    }
  )
}

# Note: S3 bucket policy for CloudTrail should be created in the logging account
# where the bucket exists. This is handled in the logging-account configuration.

