output "alb_dns_name" {
  description = "ALB DNS name (available after apply in later phases)"
  value       = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.app_tg.arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app_asg.name
}
