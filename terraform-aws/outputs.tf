output "dev_cluster_endpoint" {
  value = module.dev_eks.cluster_endpoint
}

output "prd_cluster_endpoint" {
  value = module.prd_eks.cluster_endpoint
}