variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "ksa_name" {
  description = "The name of the Kubernetes Service Account."
  type        = string
}

variable "ksa_namespace" {
  description = "The namespace of the Kubernetes Service Account."
  type        = string
}