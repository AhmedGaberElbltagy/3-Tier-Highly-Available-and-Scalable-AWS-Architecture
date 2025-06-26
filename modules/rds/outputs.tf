output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "db_instance_name" {
  description = "The name of the RDS instance"
  value       = aws_db_instance.rds_instance.db_name
}

output "db_instance_username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.rds_instance.username
}

output "db_password" {
  description = "The password for the RDS instance"
  value       = random_password.db_password.result
  sensitive   = true
}

