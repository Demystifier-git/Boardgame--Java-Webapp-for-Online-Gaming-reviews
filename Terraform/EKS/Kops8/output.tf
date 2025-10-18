output "kops_state_store" {
  value = local.kops_state_store
}

output "cluster_name" {
  value = var.cluster_name
}

output "security_group_id" {
  value = aws_security_group.kops_sg
}

output "ssh_key_name" {
  value = var.ssh_public_key_path
}

