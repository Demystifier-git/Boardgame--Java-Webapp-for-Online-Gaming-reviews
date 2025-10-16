variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "eks_cluster_name" {
  default = "Boardgame-cluster"
}
