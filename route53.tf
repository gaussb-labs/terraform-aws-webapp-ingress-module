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
