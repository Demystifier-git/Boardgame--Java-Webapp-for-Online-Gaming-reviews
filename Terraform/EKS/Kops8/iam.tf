#################################################
# Use existing EC2 role for Kops nodes
#################################################

# Reference your existing EC2 role (the one attached to the instance)
data "aws_iam_role" "kops_nodes" {
  name = "EC2"  # <-- Your existing EC2 role name
}

# Attach required AWS managed policies to that role
resource "aws_iam_role_policy_attachment" "attach_eks_worker" {
  role       = data.aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_ecr_readonly" {
  role       = data.aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_eks_cni" {
  role       = data.aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}



# Reference the existing EC2 instance profile
data "aws_iam_instance_profile" "kops_instance_profile" {
  name = "EC2"  # <-- Your existing instance profile
}




