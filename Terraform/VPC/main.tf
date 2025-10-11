terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create VPC
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

# Create Subnets
module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
  azs    = var.availability_zones
}

# Internet Gateway
module "igw" {
  source = "./modules/internet-gateway"
  vpc_id = module.vpc.vpc_id
}

# NAT Gateway
module "nat" {
  source            = "./modules/nat-gateway"
  public_subnet_id  = module.subnets.public_subnet_ids[0]   # ✅ changed
  depends_on        = [module.igw]
}

# Route Tables
module "routes" {
  source             = "./modules/route-tables"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.igw.igw_id
  nat_id             = module.nat.nat_id
  public_subnet_id   = module.subnets.public_subnet_ids[0]   # ✅ send one subnet
  private_subnet_id  = module.subnets.private_subnet_ids[0]  # ✅ send one subnet
}

# Security Group
module "security_group" {
  source   = "./modules/security-group"
  vpc_id   = module.vpc.vpc_id
  sg_name  = "web-sg"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}




