data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# EC2 Instances
resource "aws_instance" "web_server" {
    count = length(var.public_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
      subnet_id              = element(var.public_subnet_ids, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids = [var.web_security_group_id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    # Force replacement by adding a comment
    yum update -y
    amazon-linux-extras install nginx1 -y
    
    # Use cat with a heredoc to reliably create the index.html file
    cat <<'EOT' > /usr/share/nginx/html/index.html
${file("/Users/ahmedgaber/Desktop/aws-progect/code/frontend/index.html")}
EOT
    
    systemctl restart nginx
    systemctl enable nginx
    EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Project}-ec2-${var.availability_zones[count.index]}"
      Type = "EC2Instance"
      Tier = "Web"
      Role = "WebServer"
      AvailabilityZone = var.availability_zones[count.index]
      Description      = "Production web server instance ${count.index + 1}"
    }
  )
}

# App Tier EC2 Instances
resource "aws_instance" "app_server" {
  count = length(var.private_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
    subnet_id              = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids = [var.app_security_group_id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    # Install Node.js from NodeSource
    curl -sL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs
    # Install pm2 globally
    npm install pm2 -g
    # Create app directory and files
    mkdir -p /app
    cat <<'EOT' > /app/app.js
${file("/Users/ahmedgaber/Desktop/aws-progect/code/backend/app.js")}
EOT
    cat <<'EOT' > /app/package.json
${file("/Users/ahmedgaber/Desktop/aws-progect/code/backend/package.json")}
EOT
    # Install dependencies and start app
    cd /app
    npm install
    pm2 start app.js --name "backend-app"
    # Ensure pm2 restarts on reboot
    pm2 startup systemd -u root --hp /root
    EOF

  tags = merge(
    var.tags,
    {
      Name             = "${var.tags.Project}-app-ec2-${var.availability_zones[count.index]}"
      Type             = "EC2Instance"
      Tier             = "App"
      Role             = "AppServer"
      AvailabilityZone = var.availability_zones[count.index]
      Description      = "Production app server instance ${count.index + 1}"
    }
  )
}
