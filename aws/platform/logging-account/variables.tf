variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "logging"
}

variable "cloudtrail_log_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = ""
}

variable "config_log_bucket_name" {
  description = "S3 bucket name for Config logs"
  type        = string
  default     = ""
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

