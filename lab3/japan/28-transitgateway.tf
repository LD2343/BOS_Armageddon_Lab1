module "shinjuku_tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 3.1"

  name        = "shinjuku-tgw01"
  description = "Tokyo hub Transit Gateway"

  share_tgw = false

  enable_default_route_table_association = true
  enable_default_route_table_propagation = true

  vpc_attachments = {
    tokyo_vpc01 = {
      vpc_id       = aws_vpc.edo_vpc01.id
      subnet_ids   = aws_subnet.edo_private_subnets[*].id
      dns_support  = true
      ipv6_support = false
    }
  }

  tags = {
    Name        = "shinjuku-tgw01"
    Environment = "hub"
  }
}

# Peering attachment – only create when enabled (requester side)
resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade" {
  count = var.enable_tgw_peering ? 1 : 0

  transit_gateway_id      = module.shinjuku_tgw.ec2_transit_gateway_id
  peer_transit_gateway_id = var.peer_transit_gateway_id
  peer_region             = var.peer_region

  tags = { Name = "shinjuku-to-liberdade-peer01" }
}

# Associate peering to default association route table
resource "aws_ec2_transit_gateway_route_table_association" "shinjuku_peer_assoc" {
  count = var.enable_tgw_peering ? 1 : 0

  transit_gateway_attachment_id  = length(aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade) > 0 ? aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade[0].id : null
  transit_gateway_route_table_id = module.shinjuku_tgw.ec2_transit_gateway_association_default_route_table_id
}

# Propagate peering routes to default propagation route table (Tokyo learns Brazil CIDRs)
resource "aws_ec2_transit_gateway_route_table_propagation" "shinjuku_peer_to_vpc" {
  count = var.enable_tgw_peering ? 1 : 0

  transit_gateway_attachment_id  = length(aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade) > 0 ? aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade[0].id : null
  transit_gateway_route_table_id = module.shinjuku_tgw.ec2_transit_gateway_propagation_default_route_table_id
}


# Explanation: Shinjuku returns traffic to Liberdade—because doctors need answers, not one-way tunnels.
# resource "aws_route" "shinjuku_to_sp_route01" {
#   route_table_id         = aws_route_table.edo_private_rt01.id
#   destination_cidr_block = "10.55.0.0/16" # Sao Paulo VPC CIDR (students supply)
#   transit_gateway_id     = aws_ec2_transit_gateway.shinjuku_tgw01.id
# }