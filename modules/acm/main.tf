resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.san_domains

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Create DNS validation records for each domain
resource "aws_route53_record" "validation" {
  count   = length(aws_acm_certificate.acm_certificate.domain_validation_options)
  name    = aws_acm_certificate.acm_certificate.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.acm_certificate.domain_validation_options[count.index].resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.acm_certificate.domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

# Validate the certificate
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
