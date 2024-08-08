include {
  path = find_in_parent_folders()
}

dependency "eip_nat" {
  config_path  = "../eip_nat"

  mock_outputs = {
    ids = ["mocked-id"]
  }
}

terraform {
  // Documentation: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  source = "tfr:///terraform-aws-modules/vpc/aws//?version=5.0.0"
}

locals {
  environment = split("/", get_path_from_repo_root())[3]
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  name = "spring-boot-api-${local.environment}"
  cidr = "10.10.0.0/16"

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  azs = [
    "${local.region.locals.region.aws_region}a",
    "${local.region.locals.region.aws_region}b",
    "${local.region.locals.region.aws_region}c"
  ]
  public_subnets = [
    "10.10.0.0/20",
    "10.10.16.0/20",
    "10.10.32.0/20"
  ]
  private_subnets = [
    "10.10.48.0/20",
    "10.10.64.0/20",
    "10.10.80.0/20"
  ]

  vpc_tags = {
    Name = "sample-${local.environment}-${local.region.locals.region.aws_region_short}"
  }

  tags = {
    service_name = "sping-boot-api"
  }

  create_database_subnet_group       = false
  create_database_subnet_route_table = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  external_nat_ip_ids    = dependency.eip_nat.outputs.ids
  reuse_nat_ips          = true
}
