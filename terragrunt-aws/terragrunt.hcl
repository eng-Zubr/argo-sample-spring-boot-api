# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Freeze terraform version
terraform_version_constraint = "= 1.4.5"

# Freeze terragrunt version
terragrunt_version_constraint = "= 0.45.2"

locals {

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account.name
  account_id   = local.account_vars.locals.account.aws_account_id
  aws_profile  = local.account_vars.locals.account.aws_profile
  aws_region   = local.region_vars.locals.region.aws_region
  state_region = local.region_vars.locals.region.state_region

  environment = local.environment_vars.locals.environment.name
  project  = local.project_vars.locals.project.name
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider aws {
  region = "${local.aws_region}"
  profile = "${local.aws_profile}"
  # Only these AWS Account IDs may be operated on by this template
  #
  default_tags {
    tags = {
      environment  = "${local.environment}"
      repo_path    = "${path_relative_to_include()}"
      terraform    = "true"
    }
  }
 # allowed_account_ids = ["${local.account_id}"]
  skip_metadata_api_check = true
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
  backend      = "s3"
  config = {
    encrypt        = true
    bucket         = "sample-${local.account_name}-${local.environment}-${local.state_region}-terraform-remote-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "sample-${local.account_name}-${local.environment}-${local.state_region}-remote-state-lock"
    profile        = "${local.aws_profile}"

    skip_metadata_api_check = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `account.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)

