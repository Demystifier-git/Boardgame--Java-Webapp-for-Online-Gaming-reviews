#################################################
# IAM Roles and Policies for Kops8 Cluster
#################################################

# 1️⃣ Kops IAM Role for EC2 instances (nodes)
resource "aws_iam_role" "kops_nodes" {
  name = "kops-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2️⃣ Attach Managed Policies Required for EKS/Kops Nodes
resource "aws_iam_role_policy_attachment" "kops_worker_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])

  role       = aws_iam_role.kops_nodes.name
  policy_arn = each.key
}

#################################################
# 3️⃣ Additional Policies for Accessing RDS, Secrets Manager, and ALB
#################################################

# Custom inline policy
resource "aws_iam_policy" "kops_custom_policy" {
  name        = "kops-custom-policy"
  description = "Custom IAM policy for RDS, Secrets Manager, and ALB access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # RDS access (describe/read only)
      {
        Sid: "RDSAccess",
        Effect: "Allow",
        Action: [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ],
        Resource: "*"
      },

      # Secrets Manager access
      {
        Sid: "SecretsManagerAccess",
        Effect: "Allow",
        Action: [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource: "*"
      },

      # ALB and ELB access
      {
        Sid: "ALBAccess",
        Effect: "Allow",
        Action: [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer"
        ],
        Resource: "*"
      },

      # CloudWatch Logs for node logging
      {
        Sid: "CloudWatchAccess",
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

# 4️⃣ Attach Custom Policy to Node Role
resource "aws_iam_role_policy_attachment" "attach_custom_policy" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = aws_iam_policy.kops_custom_policy.arn
}

#################################################
# 5️⃣ Instance Profile for Nodes
#################################################

resource "aws_iam_instance_profile" "kops_instance_profile" {
  name = "kops-instance-profile"
  role = aws_iam_role.kops_nodes.name
}



