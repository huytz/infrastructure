variable "environments" {
  description = "Map of environments with their CIDR base configuration"
  type = map(object({
    description = string
    cidr_base   = string
  }))
  default = {}
}

variable "availability_zones" {
  description = "Map of AWS regions to their availability zones"
  type = map(list(string))
  default = {
    "us-east-1" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "us-west-2" = ["us-west-2a", "us-west-2b", "us-west-2c"]
    "eu-west-1" = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  }
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "public_subnet_offset" {
  description = "CIDR offset for public subnets (e.g., 1 means 10.0.1.0/24)"
  type        = number
  default     = 1
}

variable "private_subnet_offset" {
  description = "CIDR offset for private subnets (e.g., 10 means 10.0.10.0/24)"
  type        = number
  default     = 10
}

variable "subnet_cidr_size" {
  description = "CIDR size for subnets (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "max_azs" {
  description = "Maximum number of availability zones to use"
  type        = number
  default     = 3
}

