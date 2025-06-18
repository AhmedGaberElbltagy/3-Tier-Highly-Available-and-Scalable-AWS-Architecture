resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}"
    Type        = "VPC"
    Description = "Main VPC for production web application"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-internet-gateway"
    Type        = "InternetGateway"
    Description = "Internet Gateway for ALB public access"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name             = "${var.vpc_name}-public-subnet-${var.availability_zones[count.index]}"
    Type             = "PublicSubnet"
    Tier             = "public"
    AvailabilityZone = var.availability_zones[count.index]
    Description      = "Public subnet for ALB in ${var.availability_zones[count.index]}"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-gateway-eip"
    Type = "ElasticIP"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-gateway"
    Type = "NATGateway"
  })

  depends_on = [aws_internet_gateway.main]
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name             = "${var.vpc_name}-private-subnet-${var.availability_zones[count.index]}"
    Type             = "PrivateSubnet"
    Tier             = "private"
    AvailabilityZone = var.availability_zones[count.index]
    Description      = "Private subnet for EC2 instances in ${var.availability_zones[count.index]}"
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-database-subnet-${count.index + 1}"
    Tier = "database"
    Type = "Subnet"
  })
}

# NAT Gateways removed - no outbound internet access needed

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-public-route-table"
    Type        = "RouteTable"
    Tier        = "public"
    Description = "Route table for public subnets with internet access"
  })
}

# Private route table - no internet gateway route needed
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-private-route-table"
    Type        = "RouteTable"
    Tier        = "private"
    Description = "Route table for private subnets (no internet access)"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2" {
  name        = "${var.vpc_name}-ec2-security-group"
  description = "Security group for EC2 web servers in private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP traffic from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH access from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound traffic (limited by route table)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-ec2-security-group"
    Type        = "SecurityGroup"
    Tier        = "private"
    Description = "Security group for EC2 instances - allows HTTP from ALB and SSH from VPC"
  })
}

# Security Group for RDS
resource "aws_security_group" "database" {
  name        = "${var.vpc_name}-database-security-group"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from EC2 instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-database-security-group"
    Type = "SecurityGroup"
    Tier = "database"
  })
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.vpc_name}-alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.vpc_name}-alb-security-group"
    Type        = "SecurityGroup"
    Tier        = "public"
    Description = "Security group for ALB - allows HTTP/HTTPS from internet"
  })
}