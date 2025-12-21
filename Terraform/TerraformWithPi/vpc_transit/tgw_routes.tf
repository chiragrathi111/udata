# Transit Gateway Routing Configuration
# This file manages routes between VPCs through Transit Gateways

# Get current AWS account ID for TGW peering
data "aws_caller_identity" "current" {}

# Routes in VPC1 (us-east-1) to reach other VPCs via TGW
# These routes will be added to VPC1's route table
resource "aws_route" "vpc1_to_vpc2" {
  route_table_id         = aws_route_table.rt_vpc1.id
  destination_cidr_block = var.cidr["cidr_vpc2"]  # 13.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_east.id

  # Only depend on local TGW attachment, not cross-region peering
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc1
  ]
}

resource "aws_route" "vpc1_to_vpc3" {
  route_table_id         = aws_route_table.rt_vpc1.id
  destination_cidr_block = var.cidr["cidr_vpc3"]  # 14.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_east.id

  # Only depend on local TGW attachment, not cross-region peering
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc1
  ]
}

# Routes in VPC2 (us-west-2) to reach other VPCs via TGW
resource "aws_route" "vpc2_to_vpc1" {
  provider               = aws.vpc2
  route_table_id         = aws_route_table.rt_vpc2.id
  destination_cidr_block = var.cidr["cidr_vpc1"]  # 12.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_west.id

  # Only depend on local TGW attachment
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc2
  ]
}

resource "aws_route" "vpc2_to_vpc3" {
  provider               = aws.vpc2
  route_table_id         = aws_route_table.rt_vpc2.id
  destination_cidr_block = var.cidr["cidr_vpc3"]  # 14.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_us_west.id

  # Only depend on local TGW attachment
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc2
  ]
}

# Routes in VPC3 (eu-west-1) to reach other VPCs via TGW
resource "aws_route" "vpc3_to_vpc1" {
  provider               = aws.vpc3
  route_table_id         = aws_route_table.rt_vpc3.id
  destination_cidr_block = var.cidr["cidr_vpc1"]  # 12.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_eu_west.id

  # Only depend on local TGW attachment
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc3
  ]
}

resource "aws_route" "vpc3_to_vpc2" {
  provider               = aws.vpc3
  route_table_id         = aws_route_table.rt_vpc3.id
  destination_cidr_block = var.cidr["cidr_vpc2"]  # 13.0.0.0/16
  transit_gateway_id     = aws_ec2_transit_gateway.main_eu_west.id

  # Only depend on local TGW attachment
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc3
  ]
}

# Note: Cross-region routing will work automatically once TGW peering is established
# The TGW will handle routing between regions via the peering connections


# CRITICAL: TGW Route Table Entries for Cross-Region Communication
# These routes tell each TGW how to reach other regions via peering attachments

# Get TGW route table IDs for each region
data "aws_ec2_transit_gateway_route_table" "us_east_rt" {
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.main_us_east.id]
  }
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}

data "aws_ec2_transit_gateway_route_table" "us_west_rt" {
  provider = aws.vpc2
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.main_us_west.id]
  }
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}

data "aws_ec2_transit_gateway_route_table" "eu_west_rt" {
  provider = aws.vpc3
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.main_eu_west.id]
  }
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}

# TGW Route Table for us-east-1 TGW
# Routes to reach VPC2 (us-west-2) via peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_us_east_to_vpc2" {
  destination_cidr_block         = var.cidr["cidr_vpc2"]  # 13.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_east_to_us_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.us_east_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.us_west_accepter]
}

# Routes to reach VPC3 (eu-west-1) via peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_us_east_to_vpc3" {
  destination_cidr_block         = var.cidr["cidr_vpc3"]  # 14.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_east_to_eu_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.us_east_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.eu_west_accepter]
}

# TGW Route Table for us-west-2 TGW
# Routes to reach VPC1 (us-east-1) via peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_us_west_to_vpc1" {
  provider = aws.vpc2
  destination_cidr_block         = var.cidr["cidr_vpc1"]  # 12.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_east_to_us_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.us_west_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.us_west_accepter]
}

# Routes to reach VPC3 (eu-west-1) via direct peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_us_west_to_vpc3" {
  provider = aws.vpc2
  destination_cidr_block         = var.cidr["cidr_vpc3"]  # 14.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_west_to_eu_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.us_west_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.us_west_to_eu_west_accepter]
}

# TGW Route Table for eu-west-1 TGW
# Routes to reach VPC1 (us-east-1) via peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_eu_west_to_vpc1" {
  provider = aws.vpc3
  destination_cidr_block         = var.cidr["cidr_vpc1"]  # 12.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_east_to_eu_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.eu_west_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.eu_west_accepter]
}

# Routes to reach VPC2 (us-west-2) via direct peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_eu_west_to_vpc2" {
  provider = aws.vpc3
  destination_cidr_block         = var.cidr["cidr_vpc2"]  # 13.0.0.0/16
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_west_to_eu_west.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.eu_west_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.us_west_to_eu_west_accepter]
}