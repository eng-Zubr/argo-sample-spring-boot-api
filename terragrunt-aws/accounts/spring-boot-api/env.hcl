# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# account.hcl configuration.
locals {
  environment = {
    name = "sample"
  }
}

