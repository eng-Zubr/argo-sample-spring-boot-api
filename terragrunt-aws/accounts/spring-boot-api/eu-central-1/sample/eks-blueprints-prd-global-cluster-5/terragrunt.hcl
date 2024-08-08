include {
  path = find_in_parent_folders()
}

terraform {
  // Documentation: https://registry.terraform.io/modules/aws-ia/eks-blueprints-teams/aws/latest
  // source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"
  source = "${get_parent_terragrunt_dir()}/components//eks_blueprints"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}


dependency "eks" {
  config_path = "../eks-prd-global-cluster-5"
  mock_outputs = {
    cluster_name      = ["mocked-cluster_name"]
    oidc_provider_arn = ["mocked-oidc_provider_arn"]
    cluster_id        = ["mocked-cluster_id"]
    cluster_endpoint = ["mocked-cluster_endpoint"]
    cluster_version = ["mocked-cluster_version"]
  }
}


inputs = {
  cluster_name      = dependency.eks.outputs.cluster_name
  cluster_id        = dependency.eks.outputs.cluster_name
  cluster_endpoint  = dependency.eks.outputs.cluster_endpoint
  cluster_version   = dependency.eks.outputs.cluster_version
  oidc_provider     = dependency.eks.outputs.oidc_provider
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  eks_cluster_domain = "prod.example.com"
  argo_hostname = "argo.rod.example.com"
  external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/ZXXXXXXXXXXXXX"] // arn of example.com r53 zone
  aws_profile = local.account_vars.locals.account.aws_profile
  aws_account_id = local.account_vars.locals.account.aws_account_id
  alb_group_name = "svc-ingress-int-subprod"
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "git@github.com:aws-samples/eks-blueprints-add-ons.git"
      ssh_key_secret_name = "test-key" # add access key to aws secret manager
      add_on_application = true
    }
    backend-provisioner  = {
      path               = "argo-cd"
      repo_url            = "git@github.com:eng-Zubr/argo-sample-spring-boot-api.git"
      project             = "default"
      add_on_application  = true        # Indicates the root add-on application.
      ssh_key_secret_name = "test-key"  # Needed for private repos
      insecure            = false       # Set to true to disable the server's certificate verification
    }
  }
}

