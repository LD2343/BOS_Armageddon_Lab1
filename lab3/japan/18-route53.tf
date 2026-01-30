############################################
# Hosted Zone (optional creation)
############################################

resource "aws_route53_zone" "edo_zone01" {
  count = var.manage_route53_in_terraform ? 1 : 0

  name = local.edo_zone_name

  tags = {
    Name = "${var.project_name}-zone01"
  }
}

# ############################################
# # Route53: Zone Apex (root domain) -> ALB
# ############################################

resource "aws_route53_record" "edo_apex_to_cf01" {
  zone_id = var.route53_hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.edo_cf01.domain_name
    zone_id                = aws_cloudfront_distribution.edo_cf01.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "edo_app_to_cf01" {
  zone_id = var.route53_hosted_zone_id
  name    = "app.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.edo_cf01.domain_name
    zone_id                = aws_cloudfront_distribution.edo_cf01.hosted_zone_id
    evaluate_target_health = false
  }
}

# ############################################
# # S3 bucket for ALB access logs
# ############################################

resource "aws_s3_bucket" "edo_alb_logs_bucket01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = "edo-alb-logs-lh-${data.aws_caller_identity.edo_self01.account_id}"

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name = "${var.project_name}-alb-logs-bucket01"
  }
}

resource "aws_s3_bucket_public_access_block" "edo_alb_logs_pab01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.edo_alb_logs_bucket01[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "edo_alb_logs_owner01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.edo_alb_logs_bucket01[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "edo_alb_logs_policy01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.edo_alb_logs_bucket01[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.edo_alb_logs_bucket01[0].arn,
          "${aws_s3_bucket.edo_alb_logs_bucket01[0].arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid    = "AllowELBPutObject"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.edo_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.edo_self01.account_id}/*"
      }
    ]
  })
}