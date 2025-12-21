# Outputs for Transit Gateway Multi-Region Setup
# These provide important information about the deployed TGW infrastructure

# Transit Gateway Information
output "transit_gateways" {
  description = "Information about all Transit Gateways"
  value = {
    us_east_1 = {
      id     = aws_ec2_transit_gateway.main_us_east.id
      arn    = aws_ec2_transit_gateway.main_us_east.arn
      region = "us-east-1"
      asn    = aws_ec2_transit_gateway.main_us_east.amazon_side_asn
    }
    us_west_2 = {
      id     = aws_ec2_transit_gateway.main_us_west.id
      arn    = aws_ec2_transit_gateway.main_us_west.arn
      region = "us-west-2"
      asn    = aws_ec2_transit_gateway.main_us_west.amazon_side_asn
    }
    eu_west_1 = {
      id     = aws_ec2_transit_gateway.main_eu_west.id
      arn    = aws_ec2_transit_gateway.main_eu_west.arn
      region = "eu-west-1"
      asn    = aws_ec2_transit_gateway.main_eu_west.amazon_side_asn
    }
  }
}

# VPC Attachment Information
output "vpc_attachments" {
  description = "Transit Gateway VPC attachments"
  value = {
    vpc1 = {
      attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc1.id
      vpc_id       = aws_vpc.vpc1.id
      tgw_id       = aws_ec2_transit_gateway.main_us_east.id
      region       = "us-east-1"
    }
    vpc2 = {
      attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc2.id
      vpc_id       = aws_vpc.vpc2.id
      tgw_id       = aws_ec2_transit_gateway.main_us_west.id
      region       = "us-west-2"
    }
    vpc3 = {
      attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc3.id
      vpc_id       = aws_vpc.vpc3.id
      tgw_id       = aws_ec2_transit_gateway.main_eu_west.id
      region       = "eu-west-1"
    }
  }
}

# Peering Connection Information
output "tgw_peering_connections" {
  description = "Transit Gateway peering connections for cross-region connectivity"
  value = {
    us_east_to_us_west = {
      attachment_id = aws_ec2_transit_gateway_peering_attachment.us_east_to_us_west.id
      state        = aws_ec2_transit_gateway_peering_attachment.us_east_to_us_west.state
    }
    us_east_to_eu_west = {
      attachment_id = aws_ec2_transit_gateway_peering_attachment.us_east_to_eu_west.id
      state        = aws_ec2_transit_gateway_peering_attachment.us_east_to_eu_west.state
    }
  }
}

# VPC Information
output "vpc_information" {
  description = "VPC details for connectivity testing"
  value = {
    vpc1 = {
      id         = aws_vpc.vpc1.id
      cidr_block = aws_vpc.vpc1.cidr_block
      region     = "us-east-1"
      subnet_id  = aws_subnet.subnet_vpc1.id
    }
    vpc2 = {
      id         = aws_vpc.vpc2.id
      cidr_block = aws_vpc.vpc2.cidr_block
      region     = "us-west-2"
      subnet_id  = aws_subnet.subnet_vpc2.id
    }
    vpc3 = {
      id         = aws_vpc.vpc3.id
      cidr_block = aws_vpc.vpc3.cidr_block
      region     = "eu-west-1"
      subnet_id  = aws_subnet.subnet_vpc3.id
    }
  }
}

# Connectivity Test Instructions
output "connectivity_test_instructions" {
  description = "Instructions for testing cross-VPC connectivity"
  value = {
    overview = "Transit Gateway enables communication between VPCs across regions"
    test_steps = [
      "1. Deploy EC2 instances in each VPC",
      "2. Ensure security groups allow ICMP and SSH traffic between VPCs",
      "3. Test ping from VPC1 to VPC2: ping ${cidrhost(var.cidr["cidr_vpc2"], 10)}",
      "4. Test ping from VPC1 to VPC3: ping ${cidrhost(var.cidr["cidr_vpc3"], 10)}",
      "5. Test ping from VPC2 to VPC3: ping ${cidrhost(var.cidr["cidr_vpc3"], 10)}"
    ]
    important_notes = [
      "Ensure security groups allow traffic between VPC CIDR blocks",
      "TGW peering connections must be in 'available' state",
      "Route tables automatically propagate routes when using default settings"
    ]
  }
}

# Cost Information
output "cost_information" {
  description = "Cost considerations for Transit Gateway deployment"
  value = {
    tgw_hourly_cost = "Each TGW costs ~$36/month (24/7 operation)"
    data_processing = "Data processing charges apply for cross-AZ and cross-region traffic"
    peering_cost = "TGW peering connections have additional data transfer costs"
    total_monthly_estimate = "~$108/month for 3 TGWs + data transfer costs"
    cost_optimization = [
      "Consider consolidating VPCs in same region to reduce TGW count",
      "Monitor data transfer patterns to optimize routing",
      "Use VPC peering for simple point-to-point connections if cost is a concern"
    ]
  }
}