# Private Route53 Hosted Zone for Network Account
# Centralized DNS management for the Landing Zone
# This hosted zone can be associated with multiple VPCs across accounts

resource "aws_route53_zone" "private" {
  name = var.private_hosted_zone_name != "" ? var.private_hosted_zone_name : "network.internal"

  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = var.aws_region
  }

  tags = merge(
    {
      Name        = "network-account-private-zone"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Optional: Associate with additional VPCs from workload accounts
# This allows cross-account DNS resolution
# Note: VPCs from other accounts need to be associated via aws_route53_zone_association
# in the workload account or through cross-account IAM permissions

