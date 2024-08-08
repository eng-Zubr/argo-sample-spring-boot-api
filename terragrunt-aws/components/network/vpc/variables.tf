## This is file with possible workspace-based configuration for account

## VPC Specific configuration
variable "network" {
  description = "Bundle on network-specific variables available as a bundle"
  type = object({
    cidr : string
  })
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
}

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  type        = bool
}

variable "create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "vpc_extra_tags" {
  description = "Extra tags for the vpc"
  type        = map(string)
  default     = {}
}

locals {
  suffix   = var.environment.name != "" ? "-${var.environment.name}" : ""
  fullname = "${var.account.name}${local.suffix}"

  vpc_tags = merge(
    {
      "Name" = format("%s-vpc-%s", var.account.name, var.environment.name)
    },
    local.tags,
    var.vpc_tags
  )
}
