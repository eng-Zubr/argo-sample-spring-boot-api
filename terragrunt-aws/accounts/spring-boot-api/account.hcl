# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# account.hcl configuration.
locals {
  account = {
    name           = "spring-boot-api"
    aws_account_id = "XXXXXXXXXXXXXX"
    aws_profile    = "spring-boot-api"
  }
}
