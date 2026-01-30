# Explanation: Outputs are your mission report—what got built and where to find it.
output "gru_vpc_id" {
  value = aws_vpc.gru_vpc01.id
}

output "gru_public_subnet_ids" {
  value = aws_subnet.gru_public_subnets[*].id
}

output "gru_private_subnet_ids" {
  value = aws_subnet.gru_private_subnets[*].id
}



output "gru_sns_topic_arn" {
  value = aws_sns_topic.gru_sns_topic01.arn
}

# output "gru_log_group_name" {
#   value = aws_cloudwatch_log_group.gru_log_group01.name
# }

# output "tgw_id" {
#   description = "Transit Gateway ID in Sao Paulo"
#   value       = module.liberdade_tgw.ec2_transit_gateway_id
# }