output "web_target_group_arn" {
  description = "The ARN of the web target group"
  value       = aws_lb_target_group.web_tg.arn
}

output "app_target_group_arn" {
  description = "The ARN of the app target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "internal_app_tg_arn" {
  value = aws_lb_target_group.internal_app_tg.arn
}

output "internal_alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.main.zone_id
}
