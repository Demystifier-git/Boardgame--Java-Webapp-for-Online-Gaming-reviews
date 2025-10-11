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

# -------- S3 Bucket --------
resource "aws_s3_bucket" "tf_state" {
  bucket = "boardgame-app-2028"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}