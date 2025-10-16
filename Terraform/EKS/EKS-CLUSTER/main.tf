module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.34"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets
  cluster_endpoint_public_access = true

  # Add defaults for all managed node groups
  eks_managed_node_group_defaults = {
    ami_type = "CUSTOM"  # required for custom Ubuntu AMI
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      ami_id = "ami-0360c520857e3138f"  # Ubuntu 24.04 AMI
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      ami_id = "ami-0360c520857e3138f"  # Ubuntu 24.04 AMI
    }
  }
}

