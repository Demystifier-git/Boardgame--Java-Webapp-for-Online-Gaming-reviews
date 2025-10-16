output "cluster_name" {
  value = var.eks_cluster_name
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

