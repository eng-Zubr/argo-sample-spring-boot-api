provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  alias = "dev"
  host  = module.dev_gke.endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.dev_gke.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes" {
  alias = "prd"
  host  = module.prd_gke.endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.prd_gke.master_auth[0].cluster_ca_certificate)
}

module "vpc" {
  source  = "./modules/vpc"
  region  = var.region
  project_id = var.project_id
}

module "dev_gke" {
  source  = "./modules/gke"
  cluster_name = "dev-global-cluster-0"
  network = module.vpc.network_name
  subnetwork = module.vpc.subnet_name
  region  = var.region
  project_id = var.project_id
}

module "prd_gke" {
  source  = "./modules/gke"
  cluster_name = "prd-global-cluster-5"
  network = module.vpc.network_name
  subnetwork = module.vpc.subnet_name
  region  = var.region
  project_id = var.project_id
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
