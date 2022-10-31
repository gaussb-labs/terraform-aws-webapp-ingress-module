data "aws_route53_zone" "zone" {
  name = var.domain_name
}

resource "aws_route53_record" "alb_record" {
  name    = var.app_subdomain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
  dynamic "failover_routing_policy" {
    for_each = var.enable_failover_policy ? { value : "dummy_value" } : {}
    content {
      type = "PRIMARY"
    }
  }
  health_check_id = var.enable_failover_policy ? var.primary_record_healthcheck_id : null
  set_identifier  = var.enable_failover_policy ? "primary_${var.app_subdomain_name}" : null
}

resource "aws_route53_record" "secondary_alb_record" {
  count   = var.enable_failover_policy ? 1 : 0
  name    = var.app_subdomain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id
  alias {
    evaluate_target_health = false
    name                   = var.secondary_record_alias_name
    zone_id                = var.secondary_record_zone_id
  }
  health_check_id = var.secondary_record_healthcheck_id
  set_identifier  = "secondary_${var.app_subdomain_name}"
  failover_routing_policy {
    type = "SECONDARY"
  }
}

resource "aws_route53_record" "app_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app_subdomain.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.zone.zone_id
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
