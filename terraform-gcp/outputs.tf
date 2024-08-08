output "dev_cluster_endpoint" {
  value = module.dev_gke.endpoint
}

output "prd_cluster_endpoint" {
  value = module.prd_gke.endpoint
}
