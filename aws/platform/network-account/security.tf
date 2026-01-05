# Default security group for VPC
resource "aws_security_group" "default" {
  name        = "${local.project_name}-default-sg"
  description = "Default security group for ${local.project_name} VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all inbound traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.project_name}-default-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security group for public subnets (web tier)
resource "aws_security_group" "public" {
  name        = "${local.project_name}-public-sg"
  description = "Security group for public subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.project_name}-public-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security group for private subnets (application tier)
resource "aws_security_group" "private" {
  name        = "${local.project_name}-private-sg"
  description = "Security group for private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from public subnets"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    description = "Allow traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.project_name}-private-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

