variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "The network to deploy the GKE cluster in"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to deploy the GKE cluster in"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy to"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}
