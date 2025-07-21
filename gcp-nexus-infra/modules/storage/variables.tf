variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The primary GCP region."
  type        = string
}

variable "location" {
  description = "The location for regional resources (Cloud Storage, Artifact Registry)."
  type        = string
}