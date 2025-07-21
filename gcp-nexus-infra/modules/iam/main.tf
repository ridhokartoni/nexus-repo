resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

# GKE Service Account
resource "google_service_account" "sa_gke" {
  project      = var.project_id
  account_id   = "sa-gke"
  display_name = "GKE Service Account"  
}

# Nexus App Deployment Service Account
resource "google_service_account" "sa_nexus" {
  project      = var.project_id
  account_id   = "sa-nexus"
  display_name = "Nexus Application Service Account"
}

# IAM role bindings for the GKE Service Account
# Note: GKE requires a few standard roles to function correctly.
resource "google_project_iam_member" "gke_sa_container_node" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount" # Correct role for GKE nodes
  member  = "serviceAccount:${google_service_account.sa_gke.email}"
}

resource "google_project_iam_member" "gke_sa_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.sa_gke.email}"
}

# IAM role bindings for the Nexus Service Account
resource "google_project_iam_member" "nexus_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.sa_nexus.email}"
}

resource "google_project_iam_member" "nexus_sa_storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.sa_nexus.email}"
}

resource "google_project_iam_member" "nexus_sa_datastore_owner" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.sa_nexus.email}"
}

resource "google_service_account_iam_member" "nexus_wi_binding" {
  service_account_id = google_service_account.sa_nexus.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.ksa_namespace}/${var.ksa_name}]"
}