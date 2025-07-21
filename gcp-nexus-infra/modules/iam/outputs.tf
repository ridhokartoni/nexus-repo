output "gke_service_account_email" {
  description = "Email of the GKE service account."
  value       = google_service_account.sa_gke.email
}

output "nexus_service_account_email" {
  description = "Email of the Nexus application service account."
  value       = google_service_account.sa_nexus.email
}