# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name        = "${local.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${local.project_name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = {
    for env_key, env_config in local.subnet_configs : env_key => env_config
  }

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${each.key}-nat-eip"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create public subnets using subnet-generator module
resource "aws_subnet" "public" {
  for_each = module.subnet_generator.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name        = each.value.name
    Environment = var.environment
    Type        = "public"
    ManagedBy   = "Terraform"
  }
}

# Create private subnets using subnet-generator module
resource "aws_subnet" "private" {
  for_each = module.subnet_generator.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = each.value.name
    Environment = var.environment
    Type        = "private"
    ManagedBy   = "Terraform"
  }
}

# NAT Gateways (one per public subnet for high availability)
resource "aws_nat_gateway" "main" {
  for_each = aws_subnet.public

  # Use the lookup map to get the environment name from subnet key
  allocation_id = aws_eip.nat[local.subnet_to_env[each.key]].id
  subnet_id     = each.value.id

  tags = {
    Name        = "${each.value.tags.Name}-nat"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${local.project_name}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route tables for private subnets (one per NAT Gateway/AZ)
resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.main

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name        = "${each.value.tags.Name}-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table associations for private subnets
# Associate each private subnet with the NAT Gateway route table in the same AZ
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  # Match the route table key with the NAT gateway key (same structure: env-az)
  route_table_id = aws_route_table.private[each.key].id
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${local.project_name}-flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = {
    Name        = "${local.project_name}-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${local.project_name}-vpc-flow-logs-role"

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

  tags = {
    Name        = "${local.project_name}-vpc-flow-logs-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${local.project_name}-vpc-flow-logs-policy"
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

  tags = {
    Name        = "${local.project_name}-flow-log"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

