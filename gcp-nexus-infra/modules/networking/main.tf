terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }

  backend "gcs" {
    bucket= "ridho-nexus-bucket"
    prefix = "state/networking/main"
  }

}


# Create a custom VPC
resource "google_compute_network" "vpc_nexus" {
  project                 = var.project_id
  name                    = "vpc-nexus"
  auto_create_subnetworks = false # We want custom subnets
}

# Create the primary subnet for GKE nodes and control plane
resource "google_compute_subnetwork" "subnet_gke" {
  project                    = var.project_id
  name                       = "subnet-gke"
  ip_cidr_range              = "192.168.1.0/24"
  region                     = var.region
  network                    = google_compute_network.vpc_nexus.self_link
  private_ip_google_access = true # As requested

  # Correct way to define secondary ranges using blocks
  secondary_ip_range {
    range_name    = "subnet-pod-gke"
    ip_cidr_range = "192.168.3.0/24"
  }

  secondary_ip_range {
    range_name    = "subnet-service-gke"
    ip_cidr_range = "192.168.5.0/24"
  }
}