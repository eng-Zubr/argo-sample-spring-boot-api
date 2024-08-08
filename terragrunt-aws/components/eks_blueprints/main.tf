provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/usr/local/bin/aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["--profile", var.aws_profile, "eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["--profile", var.aws_profile, "eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "bcrypt" {}

data "aws_availability_zones" "available" {}



################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id        = var.cluster_name
  eks_cluster_endpoint  = var.cluster_endpoint
  eks_cluster_version   = var.cluster_version
  eks_oidc_provider     = var.oidc_provider
  eks_oidc_provider_arn = var.oidc_provider_arn

  enable_argocd = true
  # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
  argocd_helm_config = {
    version       = "7.1.1"
    set_sensitive = [

      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
    values = [templatefile("${path.module}/templates/argocd.yaml", { argo_hostname = var.argo_hostname, alb_group_name =  var.alb_group_name })]
  }

  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = var.argocd_applications

  # Add-ons
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_efs_csi_driver = true
  enable_aws_load_balancer_controller  = true

  enable_cert_manager                  = false
  enable_keda                          = false
  enable_karpenter                     = false
  karpenter_helm_config = {
      values = [
        <<-EOT
          settings:
            clusterName: ${var.cluster_name}
        EOT
      ]

  }

  enable_metrics_server                = true
  enable_argo_rollouts                 = false
  enable_external_secrets = false
  enable_external_dns = true
  eks_cluster_domain = var.eks_cluster_domain
  external_dns_route53_zone_arns = var.external_dns_route53_zone_arns

}

#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Argo requires the password to be bcrypt, we use custom provider of bcrypt,
# as the default bcrypt function generates diff for each terraform plan
resource "bcrypt_hash" "argo" {
  cleartext = random_password.argocd.result
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name                    = "argocd"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}