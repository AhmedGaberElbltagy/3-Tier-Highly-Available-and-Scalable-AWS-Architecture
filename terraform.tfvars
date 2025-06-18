aws_region = "us-east-1"
vpc_name   = "prod-application-vpc"
key_name   = "prod-app-keypair"
project_name = "fullstack-app-v2"

# Network Configuration
vpc_cidr             = "10.10.0.0/16"
private_subnet_cidrs = ["10.10.10.0/24", "10.10.20.0/24"]
public_subnet_cidrs  = ["10.10.100.0/24", "10.10.200.0/24"]

# Instance Configuration
instance_type = "t3.small"

# Load Balancer Configuration
alb_name          = "prod-application-alb"
target_group_name = "prod-app-servers-tg"

# Resource Tagging
common_tags = {
  Environment = "production"
  Project     = "web-application"
  Owner       = "devops-team"
  CostCenter  = "engineering"
  ManagedBy   = "terraform"
  Application = "web-app"
  Backup      = "required"
  Monitoring  = "enabled"
  CreatedDate = "2025-06-15"
  Team        = "backend-services"
}