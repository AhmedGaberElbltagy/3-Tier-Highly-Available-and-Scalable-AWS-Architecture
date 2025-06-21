# Create an internal ALB
resource "aws_lb" "internal_alb" {
  name               = "${var.alb_name}-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_security_group_id]
  subnets            = var.private_subnet_ids

  tags = var.tags
}

# Create a target group for the app servers
resource "aws_lb_target_group" "internal_app_tg" {
  name     = "${var.app_target_group_name}-internal"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

# Create a listener for the internal ALB
resource "aws_lb_listener" "internal_alb_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_app_tg.arn
  }
} 