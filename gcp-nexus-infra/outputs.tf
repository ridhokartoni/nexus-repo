output "gke_cluster_name" {
  description = "The name of the GKE cluster."
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE cluster."
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cloud_storage_bucket_name" {
  description = "The name of the Nexus Cloud Storage bucket."
  value       = module.storage.bucket_name
}

output "artifact_registry_name" {
  description = "The name of the Artifact Registry Docker repository."
  value       = module.storage.artifact_registry_repo_name
}

output "gke_service_account_email" {
  description = "The email of the service account used by GKE nodes."
  value       = module.iam.gke_service_account_email
}

output "nexus_service_account_email" {
  description = "The email of the service account for the Nexus application."
  value       = module.iam.nexus_service_account_email
}