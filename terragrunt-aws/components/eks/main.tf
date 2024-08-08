provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/usr/local/bin/aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["--profile", var.aws_profile, "eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["--profile", var.aws_profile, "eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "bcrypt" {}

locals {
  tags_b = {
    Blueprint  = var.cluster_name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.eks_ver
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    eks-pod-identity-agent = {}
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_groups = var.eks_managed_node_groups

  enable_cluster_creator_admin_permissions = true
  access_entries = {
    # One access entry with a policy associated
    Developer = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::333366803875:role/Developer"

      policy_associations = {
        Developer = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = ["*"]
            type       = "namespace"
          }
        }
      }
    }
  }


  node_security_group_tags = {
      "karpenter.sh/discovery" = var.cluster_name
  }

 authentication_mode = "API_AND_CONFIG_MAP"
}
