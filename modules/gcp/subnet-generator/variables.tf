variable "environments" {
  description = "Map of environments with their CIDR base configuration"
  type = map(object({
    description = string
    cidr_base   = string
    region      = string
  }))
  default = {}
}

variable "secondary_ranges" {
  description = "Map of secondary IP range types (e.g., pods, services)"
  type = map(object({
    range_name_suffix = string
    cidr_offset       = number
    cidr_size         = number
  }))
  default = {
    pods = {
      range_name_suffix = "pods-range"
      cidr_offset       = 1
      cidr_size         = 20
    }
    services = {
      range_name_suffix = "services-range"
      cidr_offset       = 2
      cidr_size         = 20
    }
  }
}

variable "primary_subnet_cidr_size" {
  description = "CIDR size for primary subnets (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "primary_subnet_offset" {
  description = "CIDR offset for primary subnets (e.g., 1 means 10.0.1.0/24)"
  type        = number
  default     = 1
}

