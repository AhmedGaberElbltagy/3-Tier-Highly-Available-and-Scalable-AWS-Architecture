variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID for Web Tier EC2 instances"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for App Tier EC2 instances"
  type        = string
}

variable "web_target_group_arn" {
  description = "The ARN of the web ALB's target group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "internal_app_tg_arn" {
  description = "The ARN of the internal ALB's target group"
  type        = string
}

variable "internal_alb_dns_name" {
  description = "The DNS name of the internal ALB"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones for the EC2 instances"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with the EC2 instances"
  type        = string
  default     = null
}

variable "app_code_path" {
  description = "Path to the backend application code"
  type        = string
}

variable "web_code_path" {
  description = "Path to the frontend application code"
  type        = string
}