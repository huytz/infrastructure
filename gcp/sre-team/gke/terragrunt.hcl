include "root" {
  path = find_in_parent_folders("gcp/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("gcp/root.hcl"))
}

dependency "parent" {
  config_path = find_in_parent_folders("gcp/sre-team")
  mock_outputs = {
    project_id = "sre-team-mock-project-id"
    project    = "sre-team-mock-project"
  }
}

dependency "foundation" {
  config_path = find_in_parent_folders("gcp/foundation")
  mock_outputs = {
    project_id        = "foundation-mock-project-id"
    project           = "foundation-mock-project"
    network_name      = "foundation-network"
    network_id        = "projects/foundation-mock-project-id/global/networks/foundation-network"
    network_self_link = "https://www.googleapis.com/compute/v1/projects/foundation-mock-project-id/global/networks/foundation-network"
    subnet_names = {
      "sre-team" = "sre-team-subnet"
    }
    subnet_ids = {
      "sre-team" = "projects/foundation-mock-project-id/regions/us-central1/subnetworks/sre-team-subnet"
    }
    subnet_self_links = {
      "sre-team" = "https://www.googleapis.com/compute/v1/projects/foundation-mock-project-id/regions/us-central1/subnetworks/sre-team-subnet"
    }
    subnet_ip_cidr_ranges = {
      "sre-team" = "10.0.1.0/24"
    }
    subnet_secondary_ranges = {
      "sre-team" = [
        {
          range_name    = "sre-team-pods-range"
          ip_cidr_range = "10.0.16.0/20"
        },
        {
          range_name    = "sre-team-services-range"
          ip_cidr_range = "10.0.32.0/20"
        }
      ]
    }
    subnet_configurations = {
      "sre-team" = {
        name          = "sre-team-subnet"
        ip_cidr_range = "10.0.1.0/24"
        region        = "us-central1"
        self_link     = "https://www.googleapis.com/compute/v1/projects/foundation-mock-project-id/regions/us-central1/subnetworks/sre-team-subnet"
        secondary_ranges = {
          "sre-team-pods-range" = {
            range_name    = "sre-team-pods-range"
            ip_cidr_range = "10.0.16.0/20"
          }
          "sre-team-services-range" = {
            range_name    = "sre-team-services-range"
            ip_cidr_range = "10.0.32.0/20"
          }
        }
      }
    }
  }
}

inputs = {
  # Project information
  project_id = dependency.parent.outputs.project_id
  # Foundation network information
  foundation_project_id = dependency.foundation.outputs.project_id
  network_name          = dependency.foundation.outputs.network_name
  subnet_configurations = jsonencode({
    "sre-team" = {
      name          = "sre-team-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
      self_link     = "https://www.googleapis.com/compute/v1/projects/foundation-mock-project-id/regions/us-central1/subnetworks/sre-team-subnet"
      secondary_ranges = {
        "sre-team-pods-range" = {
          range_name    = "sre-team-pods-range"
          ip_cidr_range = "10.0.16.0/20"
        }
        "sre-team-services-range" = {
          range_name    = "sre-team-services-range"
          ip_cidr_range = "10.0.32.0/20"
        }
      }
    }
  })
}
