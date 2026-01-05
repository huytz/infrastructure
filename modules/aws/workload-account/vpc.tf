# Create VPC for Workload Account
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name = "${var.account_name}-vpc"
    },
    local.common_tags
  )
}

# Create private subnets only (no public subnets - internet via Transit Gateway)
# Using subnet-generator module for consistent subnet generation
resource "aws_subnet" "private" {
  for_each = module.subnet_generator.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      Name = each.value.name
      Type = "private"
    },
    local.common_tags
  )
}

# Route tables for private subnets (one per subnet/AZ)
# All internet traffic routes through Transit Gateway to network account
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  # Route to network account via Transit Gateway
  route {
    cidr_block         = var.network_account_vpc_cidr
    transit_gateway_id = var.transit_gateway_id
  }

  # Route internet traffic (0.0.0.0/0) via Transit Gateway to network account
  # Network account will handle NAT Gateway for internet access
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = merge(
    {
      Name = "${each.value.tags.Name}-rt"
    },
    local.common_tags
  )
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.account_name}-flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    {
      Name = "${var.account_name}-flow-logs"
    },
    local.common_tags
  )
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.account_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.account_name}-vpc-flow-logs-role"
    },
    local.common_tags
  )
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.account_name}-vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.account_name}-flow-log"
    },
    local.common_tags
  )
}

