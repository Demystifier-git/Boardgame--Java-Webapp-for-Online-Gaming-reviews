output "vpc_id" { value = module.vpc.vpc_id }

output "public_subnet_ids" {
  description = "List of public subnet IDs from the subnet module"
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs from the subnet module"
  value       = module.subnets.private_subnet_ids
}

