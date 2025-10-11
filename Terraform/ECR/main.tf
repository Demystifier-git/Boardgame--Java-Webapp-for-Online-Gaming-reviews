terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Required for public ECR
}

# --- Create Public ECR Repository ---
resource "aws_ecrpublic_repository" "public_repo" {
  repository_name = "java-boardgame-webapp"

  catalog_data {
    description       = "Public repository for the Boardgame WebApp container images"
    architectures     = ["x86_64"]
    operating_systems = ["Linux"]
    about_text        = "Docker images for the Boardgame WebApp."
    usage_text        = "docker pull public.ecr.aws/<your_alias>/boardgame-webapp:latest"
  }

  tags = {
    Environment = "production"
    Project     = "java-Boardgame-Webapp"
    ManagedBy   = "Terraform"
  }
}

# --- Enable Enhanced Scanning ---
resource "aws_ecr_registry_scanning_configuration" "enhanced_scan" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {
      filter      = aws_ecrpublic_repository.public_repo.repository_name
      filter_type = "WILDCARD"
    }
  }
}

# --- Outputs ---
output "public_ecr_repository_uri" {
  description = "Full URI of your public ECR repository"
  value       = aws_ecrpublic_repository.public_repo.repository_uri
}

output "note" {
  value = "Check your public registry alias in AWS Console → ECR Public → Registry settings."
}

