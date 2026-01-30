# Certificate for ALB (regional, in ap-northeast-1)
resource "aws_acm_certificate" "edo_alb_cert01" {
  domain_name               = "app.larrryharrisaws.com"
  subject_alternative_names = ["larrryharrisaws.com", "www.larrryharrisaws.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "edo-alb-cert01"
  }
}

# Certificate for CloudFront (MUST be in us-east-1)
resource "aws_acm_certificate" "edo_cf_cert01" {
  provider = aws.use1

  domain_name               = "app.larrryharrisaws.com"
  subject_alternative_names = ["larrryharrisaws.com", "www.larrryharrisaws.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "edo-cf-cert01"
  }
}

# Validation records for ALB cert (Tokyo)
resource "aws_route53_record" "edo_alb_validation_records01" {
  for_each = {
    for dvo in aws_acm_certificate.edo_alb_cert01.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
  allow_overwrite = true
}

# Validation records for CloudFront cert (global)
resource "aws_route53_record" "edo_cf_validation_records01" {
  for_each = {
    for dvo in aws_acm_certificate.edo_cf_cert01.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
  allow_overwrite = true
}

# Validate both certificates
resource "aws_acm_certificate_validation" "edo_alb_validation01" {
  certificate_arn = aws_acm_certificate.edo_alb_cert01.arn
  validation_record_fqdns = [for r in aws_route53_record.edo_alb_validation_records01 : r.fqdn]
  timeouts { create = "30m" }
}

resource "aws_acm_certificate_validation" "edo_cf_validation01" {
  provider = aws.use1
  certificate_arn = aws_acm_certificate.edo_cf_cert01.arn
  validation_record_fqdns = [for r in aws_route53_record.edo_cf_validation_records01 : r.fqdn]
  timeouts { create = "30m" }
}