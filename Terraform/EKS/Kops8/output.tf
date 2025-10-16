output "kops_state_store" {
  value = local.kops_state_store
}

output "cluster_name" {
  value = var.cluster_name
}

output "security_group_id" {
  value = aws_security_group.kops_cluster_sg.id
}

output "ssh_key_name" {
  value = aws_key_pair.kops_key.key_name
}

output "node_role_arn" {
  description = "ARN of the IAM role for Kops nodes"
  value       = aws_iam_role.kops_nodes.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile to attach to EC2 instances"
  value       = aws_iam_instance_profile.kops_instance_profile.name
}