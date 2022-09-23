locals {
  managed_by                  = "Terraform"
  target_group_app_name       = "app"
  alb_listener_app_http_name  = "app_http"
  alb_listener_app_https_name = "app_https"
  alb_listener_rule_app_name  = "app"
}

resource "aws_lb" "alb" {
  name               = "${var.environment}-${var.alb_name}"
  subnets            = var.alb_subnets
  security_groups    = [var.http_https_ingress_sg_id]
  load_balancer_type = "application"

  access_logs {
    bucket  = aws_s3_bucket.alb_access_logs.id
    prefix  = var.alb_access_logs_prefix
    enabled = true
  }

  tags = {
    "Name"        = "${var.environment}-${var.alb_name}"
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name                 = "${var.environment}-${local.target_group_app_name}"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.target_group_deregistration_delay
  health_check {
    enabled             = var.target_group_healthcheck_enabled
    healthy_threshold   = var.target_group_healthcheck_healthy_threshold
    unhealthy_threshold = var.target_group_healthcheck_unhealthy_threshold
    interval            = var.target_group_healthcheck_interval
    matcher             = var.target_group_healthcheck_matcher
    path                = var.target_group_healthcheck_path
    port                = var.target_group_healthcheck_port
    protocol            = var.target_group_healthcheck_protocol
    timeout             = var.target_group_healthcheck_timeout
  }
  tags = {
    "Name"        = "${var.environment}-${local.target_group_app_name}"
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    "Name"        = "${var.environment}_${local.alb_listener_app_http_name}"
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}

resource "aws_lb_listener" "app_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.certificate_validation.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = var.alb_default_static_response.content_type
      message_body = base64decode(var.alb_default_static_response.encoded_message_body)
      status_code  = var.alb_default_static_response.status_code
    }
  }
  tags = {
    "Name"        = "${var.environment}_${local.alb_listener_app_https_name}"
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.app_https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
  condition {
    host_header {
      values = [var.app_subdomain_name]
    }
  }
  tags = {
    "Name"        = "${var.environment}_${local.alb_listener_rule_app_name}"
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}
