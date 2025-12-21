# Multi-Region Transit Gateway Setup
# Note: Transit Gateway can only attach to VPCs in the same region
# For cross-region connectivity, we need TGW Peering

# Transit Gateway in us-east-1 (for VPC1)
resource "aws_ec2_transit_gateway" "main_us_east" {
  description                     = "Transit Gateway for us-east-1 region"
  amazon_side_asn                 = 64512  # Private ASN for BGP
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "tgw-us-east-1"
    Region = "us-east-1"
  }
}

# Transit Gateway in us-west-2 (for VPC2)
resource "aws_ec2_transit_gateway" "main_us_west" {
  provider = aws.vpc2
  description                     = "Transit Gateway for us-west-2 region"
  amazon_side_asn                 = 64513  # Different ASN for each TGW
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "tgw-us-west-2"
    Region = "us-west-2"
  }
}

# Transit Gateway in eu-west-1 (for VPC3)
resource "aws_ec2_transit_gateway" "main_eu_west" {
  provider = aws.vpc3
  description                     = "Transit Gateway for eu-west-1 region"
  amazon_side_asn                 = 64514  # Different ASN for each TGW
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "tgw-eu-west-1"
    Region = "eu-west-1"
  }
}

# VPC Attachments (each VPC attaches to its regional TGW)
# VPC1 attachment to us-east-1 TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc1" {
  transit_gateway_id = aws_ec2_transit_gateway.main_us_east.id
  vpc_id             = aws_vpc.vpc1.id
  subnet_ids         = [aws_subnet.subnet_vpc1.id]

  tags = {
    Name = "tgw-attach-vpc1"
    VPC = "vpc1"
  }
}

# VPC2 attachment to us-west-2 TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc2" {
  provider           = aws.vpc2
  transit_gateway_id = aws_ec2_transit_gateway.main_us_west.id
  vpc_id             = aws_vpc.vpc2.id
  subnet_ids         = [aws_subnet.subnet_vpc2.id]

  tags = {
    Name = "tgw-attach-vpc2"
    VPC = "vpc2"
  }
}

# VPC3 attachment to eu-west-1 TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc3" {
  provider           = aws.vpc3
  transit_gateway_id = aws_ec2_transit_gateway.main_eu_west.id
  vpc_id             = aws_vpc.vpc3.id
  subnet_ids         = [aws_subnet.subnet_vpc3.id]

  tags = {
    Name = "tgw-attach-vpc3"
    VPC = "vpc3"
  }
}

# Transit Gateway Peering Connections for cross-region connectivity
# Peering between us-east-1 and us-west-2
resource "aws_ec2_transit_gateway_peering_attachment" "us_east_to_us_west" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region            = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.main_us_west.id
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_east.id

  tags = {
    Name = "tgw-peering-us-east-to-us-west"
  }
}

# Peering between us-east-1 and eu-west-1
resource "aws_ec2_transit_gateway_peering_attachment" "us_east_to_eu_west" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region            = "eu-west-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.main_eu_west.id
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_east.id

  tags = {
    Name = "tgw-peering-us-east-to-eu-west"
  }
}

# Accept peering attachment in us-west-2
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "us_west_accepter" {
  provider                      = aws.vpc2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_east_to_us_west.id

  tags = {
    Name = "tgw-peering-accepter-us-west"
  }
}

# Accept peering attachment in eu-west-1
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "eu_west_accepter" {
  provider                      = aws.vpc3
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_east_to_eu_west.id

  tags = {
    Name = "tgw-peering-accepter-eu-west"
  }
}

# MISSING PEERING: us-west-2 to eu-west-1 (Direct connection needed)
resource "aws_ec2_transit_gateway_peering_attachment" "us_west_to_eu_west" {
  provider                = aws.vpc2
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region            = "eu-west-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.main_eu_west.id
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_west.id

  tags = {
    Name = "tgw-peering-us-west-to-eu-west"
  }
}

# Accept peering attachment in eu-west-1
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "us_west_to_eu_west_accepter" {
  provider                      = aws.vpc3
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_west_to_eu_west.id

  tags = {
    Name = "tgw-peering-accepter-us-west-to-eu-west"
  }
}