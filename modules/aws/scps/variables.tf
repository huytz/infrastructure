variable "organization_root_id" {
  description = "AWS Organization Root ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

