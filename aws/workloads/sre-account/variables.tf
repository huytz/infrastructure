variable "account_name" {
  description = "Name of the workload account"
  type        = string
  default     = "sre"
}

variable "vpc_cidr" {
  description = "CIDR block for SRE account VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sre-account"
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

variable "transit_gateway_route_table_id_sandbox" {
  description = "Transit Gateway Route Table ID for sandbox environment"
  type        = string
}

variable "transit_gateway_route_table_id_production" {
  description = "Transit Gateway Route Table ID for production environment"
  type        = string
}

variable "transit_gateway_route_table_id_network" {
  description = "Transit Gateway Route Table ID for network account"
  type        = string
}

variable "environment_type" {
  description = "Environment type (development, sandbox, or production) for Transit Gateway route table assignment"
  type        = string
  default     = "development"
}

variable "iac_execution_account_id" {
  description = "AWS Account ID of the IaC execution account (for Terraform execution role)"
  type        = string
  default     = ""
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

variable "subnet_count" {
  description = "Number of subnets to create per availability zone"
  type        = number
  default     = 3
}

variable "subnet_cidr_offset" {
  description = "CIDR offset for private subnets"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Team = "SRE"
  }
}
