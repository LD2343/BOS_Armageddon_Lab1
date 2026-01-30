module "liberdade_tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 3.1"

  providers = {
    aws = aws.saopaulo
  }

  name        = "liberdade-tgw01"
  description = "Sao Paulo spoke Transit Gateway"

  share_tgw = false

  enable_default_route_table_association = true
  enable_default_route_table_propagation = true

  vpc_attachments = {
    sp_vpc01 = {
      vpc_id     = aws_vpc.gru_vpc01.id
      subnet_ids = aws_subnet.gru_private_subnets[*].id
      dns_support   = true
      ipv6_support  = false
    }
  }

  tags = {
    Name        = "liberdade-tgw01"
    Environment = "spoke"
  }
}

# Accept peering from Tokyo (accepter side)
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "liberdade_accept_peer01" {
  count    = var.enable_tgw_peering ? 1 : 0
  provider = aws.saopaulo

  transit_gateway_attachment_id = "tgw-attach-0c4217bbb8a6ac6ac"
  tags = {
    Name = "liberdade-accept-peer01"
  }
}

# Associate peering to default association route table
resource "aws_ec2_transit_gateway_route_table_association" "liberdade_peer_assoc" {
  count    = var.enable_tgw_peering ? 1 : 0
  provider = aws.saopaulo

  transit_gateway_attachment_id  = length(aws_ec2_transit_gateway_peering_attachment_accepter.liberdade_accept_peer01) > 0 ? aws_ec2_transit_gateway_peering_attachment_accepter.liberdade_accept_peer01[0].id : null
  transit_gateway_route_table_id = module.liberdade_tgw.ec2_transit_gateway_association_default_route_table_id
}

#Propagate peering routes to default propagation route table (São Paulo learns Tokyo CIDRs)
resource "aws_ec2_transit_gateway_route_table_propagation" "liberdade_peer_to_vpc" {
  count    = var.enable_tgw_peering ? 1 : 0
  provider = aws.saopaulo

  transit_gateway_attachment_id  = length(aws_ec2_transit_gateway_peering_attachment_accepter.liberdade_accept_peer01) > 0 ? aws_ec2_transit_gateway_peering_attachment_accepter.liberdade_accept_peer01[0].id : null
  transit_gateway_route_table_id = module.liberdade_tgw.ec2_transit_gateway_propagation_default_route_table_id
}

# Explanation: Liberdade knows the way to Shinjuku—Tokyo CIDR routes go through the TGW corridor.
# resource "aws_route" "liberdade_to_tokyo_route01" {
#   provider               = aws.saopaulo
#   route_table_id         = aws_route_table.liberdade_private_rt01.id
#   destination_cidr_block = "10." # Tokyo VPC CIDR (students supply)
#   transit_gateway_id     = aws_ec2_transit_gateway.liberdade_tgw01.id
# }