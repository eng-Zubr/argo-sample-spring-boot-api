#output "configure_kubectl" {
#  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
#}

output "random_password" {
  value = random_password.argocd.result
  sensitive = true
}