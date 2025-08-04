variable "project_id" {
  description = "The ID of the project to create the GKE cluster in"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network for the GKE cluster"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet for the GKE cluster"
  type        = string
}

variable "pods_ip_range" {
  description = "The IP range name for GKE pods"
  type        = string
}

variable "services_ip_range" {
  description = "The IP range name for GKE services"
  type        = string
}
