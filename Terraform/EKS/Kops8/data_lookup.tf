
# Reference your existing VPC by ID
data "aws_vpc" "existing" {
  id = "vpc-03a91c03159410208"  # <-- Replace with your actual VPC ID
}

# Reference existing private subnets by IDs
data "aws_subnet" "public_1" {
  id = "subnet-0bbbb9369dcaa6626"  # <-- Replace with your actual public subnet ID
}

data "aws_subnet" "public_2" {
  id = "subnet-09188e01aead282e2"  # <-- Replace with your actual public subnet ID
}





