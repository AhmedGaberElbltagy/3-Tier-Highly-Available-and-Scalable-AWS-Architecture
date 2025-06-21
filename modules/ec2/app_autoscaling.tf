# App Tier Launch Configuration
resource "aws_launch_configuration" "app_lc" {
  name_prefix     = "${var.tags.Project}-app-lc-"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.app_security_group_id]
  iam_instance_profile = var.iam_instance_profile
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
${file("${var.app_code_path}/app.js")}
EOT
    cat <<'EOT' > /app/package.json
${file("${var.app_code_path}/package.json")}
EOT
    # Install dependencies and start app
    cd /app
    npm install
    pm2 start app.js --name "backend-app"
    # Ensure pm2 restarts on reboot
    pm2 startup systemd -u root --hp /root
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# App Tier Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                 = "${var.tags.Project}-app-asg"
  launch_configuration = aws_launch_configuration.app_lc.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = var.private_subnet_ids
  target_group_arns    = [var.internal_app_tg_arn]

  tag {
    key                 = "Name"
    value               = "${var.tags.Project}-app-ec2"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "app_scale_up" {
  name                   = "${var.tags.Project}-app-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "app_scale_down" {
  name                   = "${var.tags.Project}-app-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${var.tags.Project}-app-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = [aws_autoscaling_policy.app_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "${var.tags.Project}-app-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_actions       = [aws_autoscaling_policy.app_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
} 