# ------------------------------------------------------------------------------
# AWS RDS DB SUBNET GROUP
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-subnet-group"
    Type = "DBSubnetGroup"
  })
}

# ------------------------------------------------------------------------------
# AWS RDS DB PARAMETER GROUP
# ------------------------------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-rds-parameter-group"
  family = "postgres15"

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-parameter-group"
    Type = "DBParameterGroup"
  })
}

# ------------------------------------------------------------------------------
# AWS RDS DB INSTANCE
# ------------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier          = "${var.project_name}-rds-instance"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = var.db_instance_class
  allocated_storage   = 20
  storage_type        = "gp2"
  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-instance"
    Type = "DBInstance"
  })
}
