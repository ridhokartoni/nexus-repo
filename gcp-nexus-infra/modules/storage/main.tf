# Enable the required APIs
resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "datastore_api" {
  project = var.project_id
  service = "datastore.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore_api" {
  project            = var.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

# Create the Datastore database
resource "google_firestore_database" "datastore_db" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.location # This will be us-central1
  type        = "DATASTORE_MODE"

  # Ensure the API is enabled before trying to create the database
  depends_on = [google_project_service.firestore_api]
}

# Create the Cloud Storage bucket for Nexus blobs
resource "google_storage_bucket" "nexus_bucket" {
  project  = var.project_id
  name     = "ridho-nexus-bucket" # Bucket names must be globally unique
  location = var.location
  force_destroy = true # Allows bucket deletion even if not empty
}

# Create the Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "nexus_docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = "nexus-repo"
  description   = "Docker repository for Nexus"
  format        = "DOCKER"
  depends_on = [google_project_service.artifactregistry_api]
}