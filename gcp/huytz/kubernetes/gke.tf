module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  project_id                 = var.project_id
  name                       = "gke-test"
  region                     = "us-central1"
  zones                      = ["us-central1-a"]
  network                    = var.network_name
  subnetwork                 = var.subnet_name
  ip_range_pods              = var.pods_ip_range
  ip_range_services          = var.services_ip_range
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  istio                      = false
  cloudrun                   = false
  dns_cache                  = false

  # Enable public access to the cluster
  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    },
  ]

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-a"
      min_count                 = 1
      max_count                 = 4
      local_ssd_count           = 0
      spot                      = false
      local_ssd_ephemeral_count = 0
      disk_size_gb              = 100
      disk_type                 = "pd-ssd"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = true
      auto_upgrade              = true
      preemptible               = false
      initial_node_count        = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
