# Explanation: CloudFront is the only public doorway — Chewbacca stands behind it with private infrastructure.
resource "aws_cloudfront_distribution" "edo_cf01" {
  provider        = aws.use1   # CloudFront is managed in us-east-1
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_name}-cf01"

  origin {
    origin_id   = "${var.project_name}-alb-origin01"
    domain_name = aws_lb.edo_alb01.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # Explanation: CloudFront whispers the secret growl — the ALB only trusts this.
    custom_header {
      name  = "X-edo-Growl"
      value = random_password.edo_origin_header_value01.result
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-alb-origin01"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Explanation: Attach WAF at the edge — now WAF moved to CloudFront.
  web_acl_id = aws_wafv2_web_acl.edo_cf_waf01.arn

  aliases = ["larrryharrisaws.com", "www.larrryharrisaws.com", "app.larrryharrisaws.com"]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.edo_cf_cert01.arn   # Must be from us-east-1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "random_password" "edo_origin_header_value01" {
  length           = 32
  special          = false
  override_special = "_%@"
}