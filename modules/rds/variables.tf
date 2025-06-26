variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., 'dev', 'prod')"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "rds_sg_id" {
  description = "The ID of the RDS security group"
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage for the DB instance"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "The instance class for the DB instance"
  type        = string
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}
