variable "vpc_id" { type = string }

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags = { Name = "main-igw" }
}

output "igw_id" {
  value = aws_internet_gateway.this.id
}

