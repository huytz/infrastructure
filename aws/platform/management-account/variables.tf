variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "management"
}

variable "cloudtrail_log_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (in logging account)"
  type        = string
  default     = ""
}

variable "enable_security_controls" {
  description = "Enable security controls (CloudTrail)"
  type        = bool
  default     = true
}

variable "enable_scps" {
  description = "Enable Service Control Policies"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_identity_center" {
  description = "Enable AWS IAM Identity Center (AWS SSO) for centralized access management"
  type        = bool
  default     = true
}

