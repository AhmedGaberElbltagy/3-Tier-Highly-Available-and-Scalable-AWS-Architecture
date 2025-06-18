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
resource "aws_instance" "app" {
  count = length(var.private_subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  subnet_id              = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from Terraform</h1>" > /usr/share/nginx/html/index.html
    EOF

  tags = merge(
    var.tags,
    {
      Name             = "${var.tags.Project}-ec2-${var.availability_zones[count.index]}"
      Type             = "EC2Instance"
      Tier             = "private"
      Role             = "WebServer"
      AvailabilityZone = var.availability_zones[count.index]
      Description      = "Production web server instance ${count.index + 1}"
    }
  )
}
