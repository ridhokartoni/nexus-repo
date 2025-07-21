# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }

  backend "gcs" {
    bucket= "ridho-nexus-bucket"
    prefix = "state/main"
  }


}



provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Networking Module ---
# Creates the VPC and subnets
module "networking" {
  source = "./modules/networking"

  project_id = var.gcp_project_id
  region     = var.gcp_region
}

# --- IAM Module ---
# Creates service accounts and assigns roles
module "iam" {
  source = "./modules/iam"
  project_id    = var.gcp_project_id
  ksa_name      = "nexus-ksa"
  ksa_namespace = "nexus-ns"
}

# --- Storage Module ---
# Creates Cloud Storage, Artifact Registry, and enables Datastore
module "storage" {
  source = "./modules/storage"

  project_id = var.gcp_project_id
  region     = var.gcp_region
  location   = var.gcp_region # For regional resources
}

# --- GKE Module ---
# Creates the GKE cluster using resources from other modules
module "gke" {
  source = "./modules/gke"

  project_id            = var.gcp_project_id
  region                = var.gcp_region
  zone                  = "${var.gcp_region}-a"
  network_name          = module.networking.vpc_name
  subnet_name           = module.networking.gke_subnet_name
  pod_subnet_name       = module.networking.pod_subnet_name
  service_subnet_name   = module.networking.service_subnet_name
  gke_service_account   = module.iam.gke_service_account_email
}