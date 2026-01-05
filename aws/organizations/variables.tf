variable "organization_name" {
  description = "Name of the AWS Organization"
  type        = string
  default     = "MyOrganization"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "organizations"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Organizational Units configuration
variable "organizational_units" {
  description = "Map of Organizational Units to create"
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {
    platform = {
      name        = "Platform"
      description = "Platform accounts (Security, Network, Logging)"
    }
    workloads = {
      name        = "Workloads"
      description = "Workload accounts (Dev, Sandbox, Prod)"
    }
  }
}

# Sub-OUs for Workloads
variable "workload_ous" {
  description = "Map of Workload sub-Organizational Units"
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {
    dev = {
      name        = "Dev"
      description = "Development environment accounts"
    }
    sandbox = {
      name        = "Sandbox"
      description = "Sandbox environment accounts"
    }
    prod = {
      name        = "Prod"
      description = "Production environment accounts"
    }
  }
}

# Account to OU mapping
variable "account_ou_mapping" {
  description = "Map of account names to OU keys (e.g., network -> platform, sre -> workloads/dev). Accounts will be created in these OUs. Set to empty map {} to skip account creation if accounts already exist."
  type        = map(string)
  default     = {}
}

variable "enable_account_creation" {
  description = "Enable creation of new AWS accounts. Set to false if accounts already exist and should be moved manually."
  type        = bool
  default     = true
}

variable "account_email_domain" {
  description = "Email domain for created accounts. Accounts will use pattern: aws-{account_name}@{domain}"
  type        = string
  default     = ""
}
