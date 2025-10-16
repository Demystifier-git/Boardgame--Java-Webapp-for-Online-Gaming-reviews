##################################################
# Locals
##################################################
locals {
  kops_state_store         = "s3://${var.kops_state_bucket}"
  zones_csv                = join(",", var.zones)
 ssh_pub_key_path_expanded = abspath(var.ssh_public_key_path)

}

##################################################
# S3 Bucket for Kops state store
##################################################
resource "aws_s3_bucket" "kops_state" {
  bucket = var.kops_state_bucket
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

  tags = {
    Name = "${var.cluster_name}-kops-state"
  }
}

##################################################
# Block public access to the S3 bucket
##################################################
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.kops_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

##################################################
# Load SSH public key and create AWS key pair
##################################################
data "local_file" "ssh_pubkey" {
  filename = local.ssh_pub_key_path_expanded
}

resource "aws_key_pair" "kops_key" {
  key_name   = "${replace(var.cluster_name, ".", "-")}-key"
  public_key = data.local_file.ssh_pubkey.content
}

##################################################
# Security Group for Kops Cluster
##################################################
resource "aws_security_group" "kops_cluster_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for Kops cluster"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow Kubernetes API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

##################################################
# Kops Cluster Creation
##################################################
resource "null_resource" "kops_create_cluster" {
  triggers = {
    cluster_name       = var.cluster_name
    state_bucket       = aws_s3_bucket.kops_state.bucket
    kubernetes_version = var.kubernetes_version
    zones              = join(",", var.zones)
    node_count         = tostring(var.node_count)
    node_size          = var.node_size
    master_size        = var.master_size
    ssh_key_name       = aws_key_pair.kops_key.key_name
    security_group_id  = aws_security_group.kops_cluster_sg.id
    extra_args         = var.additional_kops_create_args
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      set -euo pipefail
      export KOPS_STATE_STORE=${local.kops_state_store}

      echo "Creating Kops cluster: ${var.cluster_name}"

      kops create cluster \
        --name ${var.cluster_name} \
        --cloud aws \
        --state ${local.kops_state_store} \
        --zones ${local.zones_csv} \
        --vpc ${data.aws_vpc.existing.id} \
        --subnets ${data.aws_subnet.private_1.id},${data.aws_subnet.private_2.id} \
        --node-count ${var.node_count} \
        --node-size ${var.node_size} \
        --master-size ${var.master_size} \
        --ssh-public-key ${local.ssh_pub_key_path_expanded} \
        --kubernetes-version ${var.kubernetes_version} \
        --authorization RBAC \
        ${var.additional_kops_create_args} || true

      echo "Applying cluster changes..."
      kops update cluster --name ${var.cluster_name} --state ${local.kops_state_store} --yes

      echo "Cluster creation started! You can validate with:"
      echo "  kops validate cluster --name ${var.cluster_name} --state ${local.kops_state_store}"
    EOT
  }

  depends_on = [
    aws_s3_bucket.kops_state,
    aws_security_group.kops_cluster_sg,
    aws_key_pair.kops_key
  ]
}

