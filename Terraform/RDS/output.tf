output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "db_port" {
  description = "DB port"
  value       = aws_db_instance.mysql.port
}

output "db_identifier" {
  description = "DB instance identifier"
  value       = aws_db_instance.mysql.id
}