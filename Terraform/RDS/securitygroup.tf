# Security group to allow MySQL access (3306). In production, prefer security group references.
resource "aws_security_group" "db_sg" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for ${var.db_identifier} allowing inbound MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description      = "MySQL inbound"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = ["sg-0ff19ade5804ba9a6"]
  
    
    
  }

  
  ingress {
    description      = "MySQL inbound"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = ["sg-09501c4b44e2fc7c7"]
  
    
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_identifier}-sg"
  }
}