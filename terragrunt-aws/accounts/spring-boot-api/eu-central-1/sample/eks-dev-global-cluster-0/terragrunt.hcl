include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/components//eks"
}

dependencies {
  paths = ["../network/vpc_subprod"]
}

dependency "vpc" {
  config_path = "../network/vpc_subprod"
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  eks_ver = "1.30"
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets
  aws_profile = local.account_vars.locals.account.aws_profile
  cluster_name = "dev-global-cluster-0"
  tags = {
    "Name" = "dev-global-cluster-0"
    "k8s.io/cluster-autoscaler/enabled" = "true",
    "k8s.io/cluster-autoscaler/dev-global-cluster-0" = "owned",
  }
  eks_managed_node_groups = {
    bk-subprod-v2-base = {
      instance_types = ["t3a.medium"]
      capacity_type  = "SPOT"
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
      min_size     = 2
      max_size     = 3
      desired_size = 2
      labels = {
        layer     = "base"
      }
      termination_policies = ["OldestInstance"]
      tags = {
        EKS = "subprod"
        group = "base"
        layer = "base"
      }
    }
  }
}
