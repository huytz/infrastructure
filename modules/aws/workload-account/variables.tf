variable "account_name" {
  description = "Name of the workload account (e.g., sre, production, staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the workload account VPC (e.g., 10.1.0.0/16)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = ""
}

variable "network_account_vpc_id" {
  description = "VPC ID from network account"
  type        = string
}

variable "network_account_vpc_cidr" {
  description = "VPC CIDR block from network account"
  type        = string
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID from network account (required)"
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "Transit Gateway Route Table ID for this workload account (development, sandbox, or production route table for network isolation)"
  type        = string
}

variable "environment_type" {
  description = "Environment type (development, sandbox, or production) for tagging and route table assignment"
  type        = string
  validation {
    condition     = contains(["development", "sandbox", "production"], var.environment_type)
    error_message = "Environment type must be either 'development', 'sandbox', or 'production'."
  }
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

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_count" {
  description = "Number of subnets to create per availability zone (default: 3 for high availability)"
  type        = number
  default     = 3
}

variable "subnet_cidr_offset" {
  description = "CIDR offset for private subnets (default: 10 means subnets start at .10, .11, .12)"
  type        = number
  default     = 10
}

variable "private_hosted_zone_name" {
  description = "Name for the private Route53 hosted zone (e.g., sre.internal, production.internal). Defaults to {account_name}.internal"
  type        = string
  default     = ""
}

variable "associate_with_network_account" {
  description = "Associate private hosted zone with network account VPC for cross-account DNS resolution"
  type        = bool
  default     = true
}

variable "iac_execution_account_id" {
  description = "AWS Account ID of the IaC execution account (for Terraform execution role)"
  type        = string
  default     = ""
}

