variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "prod-application-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.20.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.100.0/24", "10.10.200.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "prod-app-keypair"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "prod-application-alb"
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = "prod-app-servers-tg"
}

variable "project_name" {
  description = "A name for the project"
  type        = string
  default     = "fullstack-app"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "dbadmin"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "web-application"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    ManagedBy   = "terraform"
    Application = "web-app"
    Backup      = "required"
    Monitoring  = "enabled"
  }
}