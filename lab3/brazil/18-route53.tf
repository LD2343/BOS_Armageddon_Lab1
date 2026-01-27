############################################
# Hosted Zone (optional creation)
############################################

# Explanation: A hosted zone is like claiming Kashyyyk in DNS—names here become law across the galaxy.
resource "aws_route53_zone" "brazil_zone01" {
  count = var.manage_route53_in_terraform ? 1 : 0

  name = local.brazil_zone_name

  tags = {
    Name = "${var.project_name}-zone01"
  }
}

# ############################################
# # Route53: Zone Apex (root domain) -> ALB
# ############################################

# # Explanation: The zone apex is the throne room—edo-growl.com itself should lead to the ALB.
# resource "aws_route53_record" "brazil_apex_alias01" {
#   zone_id = local.brazil_zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.brazil_alb01.dns_name
#     zone_id                = aws_lb.brazil_alb01.zone_id
#     evaluate_target_health = true
#   }
# }

# # App prefix mapped to ALB
# resource "aws_route53_record" "brazil_app_alias01" {
#   zone_id = local.brazil_zone_id
#   name    = local.brazil_app_fqdn
#   type    = "A"

#   alias {
#     name                   = aws_lb.brazil_alb01.dns_name
#     zone_id                = aws_lb.brazil_alb01.zone_id
#     evaluate_target_health = true
#   }
# }

############################################
# ACM DNS Validation Records
############################################

# Explanation: ACM asks “prove you own this planet”—DNS validation is edo roaring in the right place.
# resource "aws_route53_record" "brazil_acm_validation_records01" {
#   allow_overwrite = true
#   for_each = var.certificate_validation_method == "DNS" ? {
#     for dvo in aws_acm_certificate.brazil_acm_cert01.domain_validation_options :
#     dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   } : {}

#   zone_id = local.brazil_zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60

#   records = [each.value.record]
# }



############################################
# S3 bucket for ALB access logs
############################################

# Explanation: This bucket is edo’s log vault—every visitor to the ALB leaves footprints here.
resource "aws_s3_bucket" "brazil_alb_logs_bucket01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = "brazil-alb-logs-lh-891377135193"
  # #prevent s3 destroy
  # lifecycle {
  #   prevent_destroy = true
  # }
  force_destroy = true

  tags = {
    Name = "${var.project_name}-alb-logs-bucket01"
  }
}

# Explanation: Block public access—edo does not publish the ship’s black box to the galaxy.
resource "aws_s3_bucket_public_access_block" "brazil_alb_logs_pab01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket                  = aws_s3_bucket.brazil_alb_logs_bucket01[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Explanation: Bucket ownership controls prevent log delivery chaos—edo likes clean chain-of-custody.
resource "aws_s3_bucket_ownership_controls" "brazil_alb_logs_owner01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.brazil_alb_logs_bucket01[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Explanation: TLS-only—edo growls at plaintext and throws it out an airlock.
resource "aws_s3_bucket_policy" "brazil_alb_logs_policy01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.brazil_alb_logs_bucket01[0].id

  # NOTE: This is a skeleton. Students may need to adjust for region/account specifics.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.brazil_alb_logs_bucket01[0].arn,
          "${aws_s3_bucket.brazil_alb_logs_bucket01[0].arn}/*"
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
        Resource = "${aws_s3_bucket.brazil_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.brazil_self01.account_id}/*"
      }
    ]
  })
}


####################################TOKYO####ROUTES####################################################################

# Explanation: Liberdade knows the way to Shinjuku—Tokyo CIDR routes go through the TGW corridor.
resource "aws_route" "liberdade_to_tokyo_route01" {
  provider               = aws.saopaulo
  route_table_id         = aws_route_table.liberdade_private_rt01.id
  destination_cidr_block = "10.81.0.0/16" # Tokyo VPC CIDR (students supply)
  transit_gateway_id     = aws_ec2_transit_gateway.liberdade_tgw01.id
}
