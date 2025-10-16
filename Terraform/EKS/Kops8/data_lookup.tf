
# Reference your existing VPC by ID
data "aws_vpc" "existing" {
  id = "vpc-03a91c03159410208"  # <-- Replace with your actual VPC ID
}

# Reference existing private subnets by IDs
data "aws_subnet" "private_1" {
  id = "subnet-0f0bbbcb93780c182"  # <-- Replace with your actual private subnet ID
}

data "aws_subnet" "private_2" {
  id = "subnet-05ebcf5c9931e208c"  # <-- Replace with your actual private subnet ID
}

