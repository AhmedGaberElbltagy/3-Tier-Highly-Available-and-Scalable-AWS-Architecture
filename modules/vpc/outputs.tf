output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "No NAT gateways in this configuration"
  value       = []
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "web_security_group_id" {
  description = "The ID of the Web Tier security group"
  value       = aws_security_group.web.id
}

output "app_security_group_id" {
  description = "The ID of the App Tier security group"
  value       = aws_security_group.app.id
}

output "app_sg_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "rds_sg_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "internal_alb_security_group_id" {
  value = aws_security_group.internal_alb_sg.id
}
