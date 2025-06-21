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

variable "web_server_instance_ids" {
  description = "A list of web server instance IDs to attach to the web target group."
  type        = list(string)
}

variable "app_server_instance_ids" {
  description = "A list of app server instance IDs to attach to the app target group."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
