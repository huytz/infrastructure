variable "account_id" {
  description = "AWS Account ID where ECR repositories are located"
  type        = string
}

variable "webhook_url" {
  description = "ArgoCD Image Updater webhook URL endpoint"
  type        = string
}

variable "webhook_secret" {
  description = "API key/secret for authenticating with the ArgoCD Image Updater webhook"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_filter" {
  description = "Optional list of ECR repository names to filter events. If empty, all repositories will trigger events."
  type        = list(string)
  default     = []
}

variable "rule_name" {
  description = "Custom name for the EventBridge rule. If empty, defaults to 'argocd-image-updater-ecr-push'"
  type        = string
  default     = ""
}

variable "connection_name" {
  description = "Custom name for the EventBridge connection. If empty, defaults to 'argocd-image-updater-webhook'"
  type        = string
  default     = ""
}

variable "api_destination_name" {
  description = "Custom name for the API destination. If empty, defaults to 'argocd-image-updater-webhook'"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Custom name for the IAM role. If empty, defaults to 'argocd-image-updater-eventbridge-role'"
  type        = string
  default     = ""
}

variable "target_id" {
  description = "Custom ID for the EventBridge target. If empty, defaults to 'ArgocdImageUpdaterCloudEvent'"
  type        = string
  default     = ""
}

variable "api_key_header_name" {
  description = "HTTP header name for the API key authentication"
  type        = string
  default     = "X-Webhook-Secret"
}

variable "invocation_rate_limit_per_second" {
  description = "Maximum number of invocations per second for the API destination"
  type        = number
  default     = 10
}

variable "maximum_event_age_in_seconds" {
  description = "Maximum age in seconds for events before they are discarded"
  type        = number
  default     = 3600
}

variable "maximum_retry_attempts" {
  description = "Maximum number of retry attempts for failed invocations"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
