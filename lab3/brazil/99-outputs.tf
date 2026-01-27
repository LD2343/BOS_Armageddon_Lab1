# Explanation: Outputs are your mission report—what got built and where to find it.
output "brazil_vpc_id" {
  value = aws_vpc.brazil_vpc01.id
}

output "brazil_public_subnet_ids" {
  value = aws_subnet.brazil_public_subnets[*].id
}

output "brazil_private_subnet_ids" {
  value = aws_subnet.brazil_private_subnets[*].id
}

output "brazil_ec2_instance_id" {
  value = aws_instance.brazil_ec201_private_bonus.id
}

# output "brazil_rds_endpoint" {
#   value = aws_db_instance.brazil_rds01.address
# }

output "brazil_sns_topic_arn" {
  value = aws_sns_topic.brazil_sns_topic01.arn
}

output "brazil_log_group_name" {
  value = aws_cloudwatch_log_group.brazil_log_group01.name
}

#Bonus-A outputs (append to outputs.tf)

# Explanation: These outputs prove brazil built private hyperspace lanes (endpoints) instead of public chaos.
# output "brazil_vpce_ssm_id" {
#   value = aws_vpc_endpoint.brazil_vpce_ssm01.id
# }

# output "brazil_vpce_logs_id" {
#   value = aws_vpc_endpoint.brazil_vpce_logs01.id
# }

# output "brazil_vpce_secrets_id" {
#   value = aws_vpc_endpoint.brazil_vpce_secrets01.id
# }

# output "brazil_vpce_s3_id" {
#   value = aws_vpc_endpoint.brazil_vpce_s3_gw01.id
# }

# output "brazil_private_ec2_instance_id_bonus" {
#   value = aws_instance.brazil_ec201_private_bonus.id
# }

# # Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
# output "brazil_alb_dns_name" {
#   value = aws_lb.brazil_alb01.dns_name
# }

# output "brazil_app_fqdn" {
#   value = "${var.app_subdomain}.${var.domain_name}"
# }

# output "brazil_target_group_arn" {
#   value = aws_lb_target_group.brazil_tg01.arn
# }

# output "brazil_acm_cert_arn" {
#   value = aws_acm_certificate.brazil_acm_cert01.arn
# }

# output "brazil_waf_arn" {
#   value = var.enable_waf ? aws_wafv2_web_acl.brazil_cf_waf01.arn : null
# }

# output "brazil_dashboard_name" {
#   value = aws_cloudwatch_dashboard.brazil_dashboard01.dashboard_name
# }

# output "brazil_route53_zone_id" {
#   value = local.brazil_zone_id
# }

# output "brazil_app_url_https" {
#   value = "https://${var.app_subdomain}.${var.domain_name}"
# }

# output "brazil_apex_url_https" {
#   value = "https://${var.domain_name}"
# }

# output "brazil_alb_logs_bucket_name" {
#   value = var.enable_alb_access_logs ? aws_s3_bucket.brazil_alb_logs_bucket01[0].bucket : null
# }

# output "brazil_waf_log_destination" {
#   value = var.waf_log_destination
# }

# output "brazil_waf_cw_log_group_name" {
#   value = var.waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.brazil_waf_log_group01[0].name : null
# }


# variable "enable_waf_sampled_requests_only" {
#   description = "If true, students can optionally filter/redact fields later. (Placeholder toggle.)"
#   type        = bool
#   default     = false
# }


# output "current_growl_secret" {
#   value     = random_password.brazil_origin_header_value01.result
#   sensitive = true
# }