# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "database_subnet_ids" {
  description = "A list of subnet IDs for the RDS database"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "The ID of the security group for the RDS database"
  type        = string
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------
variable "db_instance_class" {
  description = "The instance class for the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
