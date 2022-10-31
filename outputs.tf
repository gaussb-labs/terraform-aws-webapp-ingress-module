output "alb_arn" {
  description = "ARN for the application load balancer provisioned by this module"
  value       = aws_lb.alb.arn
}

output "alb_http_listener_arn" {
  description = "ARN for the application load balancer HTTP listener"
  value       = aws_lb_listener.app_http.arn
}

output "alb_https_listener_arn" {
  description = "ARN for the application load balancer HTTPS listener"
  value       = aws_lb_listener.app_https.arn
}

output "app_target_group_arn" {
  description = "ARN for the application target group"
  value       = aws_lb_target_group.app.arn
}

output "app_subdomain_acm_cert_arn" {
  description = "ARN for the application subdomain SSL certificate managed by ACM"
  value       = aws_acm_certificate.app_subdomain.arn
}
