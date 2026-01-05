variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "network-account"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs"
  type        = number
  default     = 7
}

variable "private_hosted_zone_name" {
  description = "Name for the private Route53 hosted zone (e.g., network.internal, company.internal). Defaults to network.internal"
  type        = string
  default     = ""
}

variable "iac_execution_account_id" {
  description = "AWS Account ID of the management/execution account (for OrganizationAccountAccessRole). This is typically the management account or a dedicated IaC execution account."
  type        = string
  default     = ""
}

variable "organization_role_name" {
  description = "Name of the IAM role for organization account access. Defaults to OrganizationAccountAccessRole following AWS Organizations best practices."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "workload_environments" {
  description = "Map of workload environments with their VPC CIDRs and environment type for Transit Gateway route table isolation"
  type = map(object({
    vpc_cidr    = string
    environment = string # "development", "sandbox", or "production" for route table assignment
  }))
  default = {
    sre = {
      vpc_cidr    = "10.1.0.0/16"
      environment = "development"
    }
  }
}

