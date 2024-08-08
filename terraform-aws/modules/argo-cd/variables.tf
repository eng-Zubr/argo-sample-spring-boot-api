variable "namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "context" {
  description = "Context (dev or prd)"
  type        = string
}
