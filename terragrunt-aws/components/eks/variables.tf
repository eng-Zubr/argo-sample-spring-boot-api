variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "eks_ver" {
  type = string
}

variable "eks_managed_node_groups" {  
  type = any
}

variable "aws_profile" {
  type = string
}
