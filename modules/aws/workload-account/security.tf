# Default security group for VPC
resource "aws_security_group" "default" {
  name        = "${var.account_name}-default-sg"
  description = "Default security group for ${var.account_name} VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all inbound traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Allow traffic from network account VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.network_account_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic (internet via Transit Gateway)"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.account_name}-default-sg"
    },
    local.common_tags
  )
}

# Security group for private subnets (application tier)
# Note: All subnets are private - internet access via Transit Gateway to network account
resource "aws_security_group" "private" {
  name        = "${var.account_name}-private-sg"
  description = "Security group for private subnets (internet via Transit Gateway)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Allow traffic from network account VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.network_account_vpc_cidr]
  }

  # Allow HTTP/HTTPS from network account (for load balancers in network account)
  ingress {
    description = "HTTP from network account"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_account_vpc_cidr]
  }

  ingress {
    description = "HTTPS from network account"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.network_account_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic (internet via Transit Gateway to network account)"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.account_name}-private-sg"
    },
    local.common_tags
  )
}

