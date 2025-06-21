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

# Web Tier Launch Configuration
resource "aws_launch_configuration" "web_lc" {
  name_prefix     = "${var.tags.Project}-web-lc-"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.web_security_group_id]
  iam_instance_profile = var.iam_instance_profile
  user_data = <<-EOF
    #!/bin/bash
    # Force replacement by adding a comment
    yum update -y
    amazon-linux-extras install nginx1 -y
    
    # Use cat with a heredoc to reliably create the index.html file
    cat <<'EOT' > /usr/share/nginx/html/index.html
${replace(file("${var.web_code_path}/index.html"), "http://localhost:3000", "http://${var.internal_alb_dns_name}")}
EOT
    
    systemctl restart nginx
    systemctl enable nginx
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Web Tier Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                 = "${var.tags.Project}-web-asg"
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = var.public_subnet_ids
  target_group_arns    = [var.web_target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.tags.Project}-web-ec2"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "web_scale_up" {
  name                   = "${var.tags.Project}-web-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

resource "aws_autoscaling_policy" "web_scale_down" {
  name                   = "${var.tags.Project}-web-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "${var.tags.Project}-web-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = [aws_autoscaling_policy.web_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_low" {
  alarm_name          = "${var.tags.Project}-web-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_actions       = [aws_autoscaling_policy.web_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
} 