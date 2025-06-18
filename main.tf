terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "app_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.app_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.app_key.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  tags = var.common_tags
}

# RANDOM PASSWORD FOR DATABASE
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()_+-=[]{}|;':,.<>?"
}

# AWS SECRETS MANAGER
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-db-credentials"
  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = <<EOF
    {
      "username": "${var.db_username}",
      "password": "${random_password.db_password.result}"
    }
  EOF
}

# RDS DATABASE MODULE
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  database_subnet_ids  = module.vpc.database_subnet_ids
  db_security_group_id = module.vpc.database_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = random_password.db_password.result

  tags = var.common_tags
}

# IAM ROLE FOR EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "${var.project_name}-secrets-manager-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  instance_type        = var.instance_type
  key_name             = var.key_name
  private_subnet_ids   = module.vpc.private_subnet_ids
  security_group_id    = module.vpc.ec2_security_group_id
  availability_zones   = data.aws_availability_zones.available.names
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = var.common_tags
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  alb_name              = var.alb_name
  target_group_name     = var.target_group_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
  instance_ids          = module.ec2.instance_ids

  tags = var.common_tags
}


