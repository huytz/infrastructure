include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "huytz" {
  config_path = "../"
  mock_outputs = {
    project_id = "fake-project-id"
  }
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_name = "gke-network"
    subnet_name = "gke-subnet"
    pods_ip_range = "pods"
    services_ip_range = "services"
  }
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

inputs = {
  project_id = dependency.huytz.outputs.project_id
  network_name = dependency.network.outputs.network_name
  subnet_name = dependency.network.outputs.subnet_name
  pods_ip_range = dependency.network.outputs.pods_ip_range
  services_ip_range = dependency.network.outputs.services_ip_range
}
