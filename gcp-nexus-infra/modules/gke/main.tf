# Enable the GKE API
resource "google_project_service" "gke_api" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# Create the GKE Cluster
resource "google_container_cluster" "primary" {
  project    = var.project_id
  name       = "nexus-gke-cluster"
  location   = var.zone

  # Networking configuration
  network    = var.network_name
  subnetwork = var.subnet_name
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_subnet_name
    services_secondary_range_name = var.service_subnet_name
  }
  
  # We are using the main subnet for the control plane, as requested.
  private_cluster_config {
    enable_private_nodes    = true # Recommended for security
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "192.168.100.0/28" # A dedicated range for the master
  }

  # Node pool configuration
  remove_default_node_pool = true
  initial_node_count       = 1

  # --- ADD THIS BLOCK TO ENABLE WORKLOAD IDENTITY --- ✅
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  depends_on = [google_project_service.gke_api]
}

# Create a custom node pool with the specified settings
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "primary-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    service_account = var.gke_service_account

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}