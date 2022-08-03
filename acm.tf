resource "aws_acm_certificate" "app_subdomain" {
  domain_name       = var.app_subdomain_name
  validation_method = "DNS"

  tags = {
    "Name"      = "${var.environment}_${var.app_subdomain_name}"
    "ManagedBy" = local.managed_by
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.app_subdomain.arn
  validation_record_fqdns = [for record in aws_route53_record.app_validation : record.fqdn]
}
