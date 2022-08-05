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
