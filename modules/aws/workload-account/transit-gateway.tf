# Transit Gateway VPC Attachment for Workload Account
# Attaches to Transit Gateway created in network-account
# Uses private subnets for attachment (no public subnets in workload accounts)
resource "aws_ec2_transit_gateway_vpc_attachment" "workload_account" {
  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = merge(
    {
      Name        = "${var.account_name}-tgw-attachment"
      Environment = var.environment_type
    },
    local.common_tags
  )
}

# Associate workload account attachment with the appropriate Transit Gateway route table
# This ensures network isolation: dev and prod accounts cannot communicate with each other
resource "aws_ec2_transit_gateway_route_table_association" "workload_account" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.workload_account.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# Propagate routes from workload account to Transit Gateway route table
# This allows other accounts in the same environment to reach this account
resource "aws_ec2_transit_gateway_route_table_propagation" "workload_account" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.workload_account.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

