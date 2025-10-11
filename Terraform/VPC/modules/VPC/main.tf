resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "main-vpc" }
}

output "vpc_id" {
  value = aws_vpc.this.id
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

