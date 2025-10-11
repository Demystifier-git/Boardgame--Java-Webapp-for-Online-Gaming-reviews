variable "public_subnet_id" { type = string }

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id
  tags = { Name = "nat-gateway" }
}

output "nat_id" {
  value = aws_nat_gateway.this.id
}

