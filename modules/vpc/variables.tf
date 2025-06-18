variable "vpc_name" {
  description = "prod-application-vpc"
  type        = string
}
variable "vpc_cidr" {
  description = "10.10.0.0/16"
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
  default     = ["10.10.10.0/24", "10.10.20.0/24"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
  default     = ["10.10.100.0/24", "10.10.200.0/24"]
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "List of database subnet CIDR blocks"
  default     = ["10.10.30.0/24", "10.10.40.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "web-application"
    Owner       = "team-a"
  }
}




