# DB subnet group - requires private_subnet_ids to be provided
resource "aws_db_subnet_group" "db_subnets" {
  count       = length(var.private_subnet_ids) > 0 ? 1 : 0
  name        = "${var.db_identifier}-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "DB subnet group for ${var.db_identifier}"
  tags = {
    Name = "${var.db_identifier}-db-subnet-group"
  }
}