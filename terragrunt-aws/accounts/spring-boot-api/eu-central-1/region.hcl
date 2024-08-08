# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  region = {
    aws_region       = "eu-central-1"
    aws_region_short = "euc1"
    state_region     = "eu-central-1"
  }
}