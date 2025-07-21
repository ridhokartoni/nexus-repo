variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "zone" {
  type = string
}
variable "network_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "pod_subnet_name" {
  type = string
}
variable "service_subnet_name" {
  type = string
}
variable "gke_service_account" {
  description = "The email of the service account for GKE nodes."
  type        = string
}