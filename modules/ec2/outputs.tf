output "web_server_instance_ids" {
  description = "IDs of the web server EC2 instances"
  value       = aws_instance.web_server[*].id
}

output "app_server_instance_ids" {
  description = "IDs of the app server EC2 instances"
  value       = aws_instance.app_server[*].id
}

output "web_server_private_ips" {
  description = "Private IP addresses of the web server EC2 instances"
  value       = aws_instance.web_server[*].private_ip
}

output "app_server_private_ips" {
  description = "Private IP addresses of the app server EC2 instances"
  value       = aws_instance.app_server[*].private_ip
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}