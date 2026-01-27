############################################
# Locals (naming convention: brazil-*) (Brotherhood Of Steel)
############################################
locals {
  name_prefix = var.project_name
}

############################################
# Bonus A - Data + Locals
############################################

# Explanation: brazil wants to know “who am I in this galaxy?” so ARNs can be scoped properly.
data "aws_caller_identity" "brazil_self01" {}

# Explanation: Region matters—hyperspace lanes change per sector.
data "aws_region" "brazil_region01" {}

locals {
  # Explanation: Name prefix is the roar that echoes through every tag.
  brazil_prefix = var.project_name

  # TODO: Students should lock this down after apply using the real secret ARN from outputs/state
  brazil_secret_arn_guess = "arn:aws:secretsmanager:${data.aws_region.brazil_region01.region}:${data.aws_caller_identity.brazil_self01.account_id}:secret:${local.brazil_prefix}/rds/mysql*"
}

############################################
# Bonus B - ALB (Public) -> Target Group (Private EC2) + TLS + WAF + Monitoring
############################################

locals {
  # Explanation: This is the roar address — where the galaxy finds your app.
  brazil_fqdn = "${var.app_subdomain}.${var.domain_name}"
}

############################################
# Bonus B - Route53 (Hosted Zone + DNS records + ACM validation + ALIAS to ALB)
############################################

locals {
  # Explanation: Chewbacca needs a home planet—Route53 hosted zone is your DNS territory.
  brazil_zone_name = var.domain_name

  # Explanation: Use either Terraform-managed zone or a pre-existing zone ID (students choose their destiny).
  # brazil_zone_id = var.manage_route53_in_terraform ? aws_route53_zone.brazil_zone01[0].zone_id : var.route53_hosted_zone_id
  brazil_zone_id = var.route53_hosted_zone_id
  # Explanation: This is the app address that will growl at the galaxy (app.chewbacca-growl.com).
  brazil_app_fqdn = "${var.app_subdomain}.${var.domain_name}"
}

### Data
### Lab 2B
# Explanation: Chewbacca only opens the hangar to CloudFront — everyone else gets the Wookiee roar.
data "aws_ec2_managed_prefix_list" "brazil_cf_origin_facing01" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Managed AWS policy that disables caching entirely (TTL=0 everywhere, none for cookies/queries/headers)
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader" # Forwards viewer Host, cookies, queries, etc.
}

data "aws_cloudfront_origin_request_policy" "brazil_orp_all_viewer01" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "brazil_orp_all_viewer_except_host01" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_cache_policy" "brazil_use_origin_cache_headers01" {
  name = "UseOriginCacheControlHeaders"
}

# Explanation: Same idea, but includes query strings in the cache key when your API truly varies by them.
data "aws_cloudfront_cache_policy" "brazil_use_origin_cache_headers_qs01" {
  name = "UseOriginCacheControlHeaders-QueryStrings"
}

# Look up the Sao Paulo (Liberdade) Transit Gateway from brazil
# data "aws_ec2_transit_gateway" "liberdade_tgw01" {
#   provider = aws.brazil   # ← assumes you have this alias for sa-east-1

#   # Option A: Hard-code the real ID (fastest, get from console)
#   id = "tgw-07d809a3dbca24edb"   # ← PASTE THE ACTUAL SAO PAULO TGW ID HERE

#   # Option B: Use tag lookup (more flexible if ID changes)
#   # filter {
#   #   name   = "tag:Name"
#   #   values = ["brazil-medical-liberdade-tgw01", "*liberdade*tgw*"]
#   # }

#   filter {
#     name   = "state"
#     values = ["available"]
#   }

#   # Safety: only your account
#   filter {
#     name   = "owner-id"
#     values = [var.aws_account_id]
#   }
# }

# Add this data source to read from the Japan configuration (apply Japan first to create the output)
data "terraform_remote_state" "japan" {
  backend = "local"
  config = {
    path = "../japan/terraform.tfstate"  # Adjust if your folder structure differs (e.g., "../../japan/terraform.tfstate")
  }
}