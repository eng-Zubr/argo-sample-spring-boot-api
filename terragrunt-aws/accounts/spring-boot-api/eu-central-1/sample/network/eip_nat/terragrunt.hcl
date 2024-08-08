include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/components//eip_nat"
}

locals {
  environment = split("/", get_path_from_repo_root())[3]
}

inputs = {
  project_name = "spring-boot-api-${local.environment}"
  num_eips = 1
}