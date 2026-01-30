# ############################################
# # S3 bucket for ALB access logs
# ############################################

# # Explanation: This bucket is edo’s log vault—every visitor to the ALB leaves footprints here.
resource "aws_s3_bucket" "gru_alb_logs_bucket01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = "gru-alb-logs-lh-891377135193"
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
resource "aws_s3_bucket_public_access_block" "gru_alb_logs_pab01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket                  = aws_s3_bucket.gru_alb_logs_bucket01[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Explanation: Bucket ownership controls prevent log delivery chaos—edo likes clean chain-of-custody.
resource "aws_s3_bucket_ownership_controls" "gru_alb_logs_owner01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.gru_alb_logs_bucket01[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# # Explanation: TLS-only—edo growls at plaintext and throws it out an airlock.
resource "aws_s3_bucket_policy" "gru_alb_logs_policy01" {
  count = var.enable_alb_access_logs ? 1 : 0

  bucket = aws_s3_bucket.gru_alb_logs_bucket01[0].id

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
          aws_s3_bucket.gru_alb_logs_bucket01[0].arn,
          "${aws_s3_bucket.gru_alb_logs_bucket01[0].arn}/*"
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
        Resource = "${aws_s3_bucket.gru_alb_logs_bucket01[0].arn}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.gru_self01.account_id}/*"
      }
    ]
  })
}


