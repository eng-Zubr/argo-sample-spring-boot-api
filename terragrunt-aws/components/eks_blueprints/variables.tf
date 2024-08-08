variable "cluster_name" {
  type = string
}
variable "oidc_provider_arn" {
  type = string
}
variable "cluster_id" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "oidc_provider" {
  type = string
}
variable "cluster_certificate_authority_data" {
  type = string
}

variable "argo_hostname" {
  type = string
}

variable "argocd_applications" {
  type = any
}

variable "eks_cluster_domain" {
  type = string
}

variable "external_dns_route53_zone_arns" {
  type = list
}

variable "aws_profile" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "alb_group_name" {
  type = string
}
