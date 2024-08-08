variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}
