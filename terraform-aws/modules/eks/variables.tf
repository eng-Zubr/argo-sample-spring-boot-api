variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to deploy the EKS cluster to"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy the EKS cluster to"
  type        = list(string)
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}
