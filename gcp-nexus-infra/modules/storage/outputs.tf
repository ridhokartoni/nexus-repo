output "bucket_name" {
  description = "The name of the Cloud Storage bucket."
  value       = google_storage_bucket.nexus_bucket.name
}

output "artifact_registry_repo_name" {
  description = "The name of the Artifact Registry repository."
  value       = google_artifact_registry_repository.nexus_docker_repo.name
}