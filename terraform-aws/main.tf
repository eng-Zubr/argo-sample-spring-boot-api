provider "aws" {
  region = var.region
}

provider "kubernetes" {
  alias = "dev"
  host  = module.dev_eks.cluster_endpoint
  token = data.aws_eks_cluster_auth.dev.token
  cluster_ca_certificate = base64decode(module.dev_eks.cluster_certificate_authority_data)
}

provider "kubernetes" {
  alias = "prd"
  host  = module.prd_eks.cluster_endpoint
  token = data.aws_eks_cluster_auth.prd.token
  cluster_ca_certificate = base64decode(module.prd_eks.cluster_certificate_authority_data)
}

module "vpc" {
  source  = "./modules/vpc"
  region  = var.region
}

module "dev_eks" {
  source  = "./modules//eks"
  cluster_name = "dev-global-cluster-0"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  region = var.region
}

module "prd_eks" {
  source  = "./modules/eks"
  cluster_name = "prd-global-cluster-5"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  region = var.region
}

module "argo_cd_dev" {
  source      = "./modules/argo-cd"
  providers   = { kubernetes = kubernetes.dev }
  namespace   = "argocd"
  context     = "dev"
}

module "argo_cd_prd" {
  source      = "./modules/argo-cd"
  providers   = { kubernetes = kubernetes.prd }
  namespace   = "argocd"
  context     = "prd"
}