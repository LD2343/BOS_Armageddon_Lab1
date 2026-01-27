# # RDS
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_gruup

# # RDS Subnet gruup
# resource "aws_db_subnet_gruup" "gru_rds_subnet_gruup01" {
#   name       = "${local.name_prefix}-rds-subnet-gruup01"
#   subnet_ids = aws_subnet.gru_private_subnets[*].id

#   tags = {
#     Name = "${local.name_prefix}-rds-subnet-gruup01"
#   }
# }

# # RDS Instance
# resource "aws_db_instance" "gru_rds01" {
#   identifier        = "${local.name_prefix}-rds01"
#   engine            = var.db_engine
#   instance_class    = var.db_instance_class
#   allocated_storage = 20
#   db_name           = var.db_name
#   username          = var.db_username
#   password          = var.db_password

#   db_subnet_gruup_name   = aws_db_subnet_gruup.gru_rds_subnet_gruup01.name
#   vpc_security_gruup_ids = [aws_security_gruup.gru_rds_sg01.id]

#   publicly_accessible = false
#   skip_final_snapshot = true

#   # TODO: student sets multi_az / backups / monitoring as stretch goals

#   tags = {
#     Name = "${local.name_prefix}-rds01"
#   }
# }