############################################
# Locals (naming convention: gro-*) (Brotherhood Of Steel)
############################################
locals {
  name_prefix = var.project_name
}

# Add this data source to read from the Japan configuration (apply Japan first to create the output)
# data "terraform_remote_state" "japan" {
#   backend = "local"
#   config = {
#     path = "edo/ap-east-1/terraform.tfstate"  # Adjust if your folder structure differs (e.g., "../../japan/terraform.tfstate")
#   }
# }

locals {
  # Explanation: Name prefix is the roar that echoes through every tag.
  gru_prefix = var.project_name

  # TODO: Students should lock this down after apply using the real secret ARN from outputs/state
  gru_secret_arn_guess = "arn:aws:secretsmanager:${data.aws_region.gru_region01.region}:${data.aws_caller_identity.gru_self01.account_id}:secret:${local.gru_prefix}/rds/mysql*"
}
data "aws_ec2_managed_prefix_list" "gru_cf_origin_facing01" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}
# Explanation: edo wants to know “who am I in this galaxy?” so ARNs can be scoped properly.
data "aws_caller_identity" "gru_self01" {}

# Explanation: Region matters—hyperspace lanes change per sector.
data "aws_region" "gru_region01" {}
