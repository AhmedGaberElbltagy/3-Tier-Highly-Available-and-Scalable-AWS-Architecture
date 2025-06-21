variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "web_target_group_name" {
  description = "The name of the web target group."
  type        = string
}

variable "app_target_group_name" {
  description = "The name of the app target group."
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

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "internal_alb_security_group_id" {
  description = "The ID of the security group for the internal ALB"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}
