output "vpc_name" {
  description = "The name of the VPC."
  value       = google_compute_network.vpc_nexus.name
}

output "gke_subnet_name" {
  description = "The name of the primary GKE subnet."
  value       = google_compute_subnetwork.subnet_gke.name
}

output "pod_subnet_name" {
  description = "The name of the secondary subnet for GKE pods."
  value       = google_compute_subnetwork.subnet_gke.secondary_ip_range[0].range_name
}

output "service_subnet_name" {
  description = "The name of the secondary subnet for GKE services."
  value       = google_compute_subnetwork.subnet_gke.secondary_ip_range[1].range_name
}