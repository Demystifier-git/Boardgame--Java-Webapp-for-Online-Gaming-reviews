resource "aws_db_instance" "mysql" {
  identifier              = var.db_identifier
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage

  username                = local.db_user
  password                = local.db_password
  db_name                 = local.db_name

  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_days
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = length(aws_db_subnet_group.db_subnets) > 0 ? aws_db_subnet_group.db_subnets[0].name : null

  storage_type = "gp3"
  apply_immediately = false

  tags = {
    Name = var.db_identifier
  }

  deletion_protection = false
}