# ------------------------------------------------------------------------------
# OUTPUTS
# ------------------------------------------------------------------------------
output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "The name of the RDS instance"
  value       = aws_db_instance.main.db_name
}
