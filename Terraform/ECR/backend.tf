# -------- Terraform Backend --------
terraform {
  backend "s3" {
    bucket         = "boardgame-app-2028"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-safe-locks"
    encrypt        = true
  }
}

