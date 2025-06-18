variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to attach to the target group"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
