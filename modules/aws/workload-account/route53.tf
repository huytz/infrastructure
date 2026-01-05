# Private Route53 Hosted Zone for Workload Account
# Used for internal DNS resolution within the account
# Following AWS Landing Zone best practices for private DNS

resource "aws_route53_zone" "private" {
  name = var.private_hosted_zone_name != "" ? var.private_hosted_zone_name : "${var.account_name}.internal"

  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = var.aws_region
  }

  tags = merge(
    {
      Name = "${var.account_name}-private-zone"
    },
    local.common_tags
  )
}

# Associate private hosted zone with network account VPC for cross-account DNS resolution
# This allows resources in the network account to resolve DNS names in the workload account
# Note: Requires proper IAM permissions for cross-account VPC association
resource "aws_route53_zone_association" "network_account" {
  count = var.associate_with_network_account ? 1 : 0

  zone_id = aws_route53_zone.private.zone_id
  vpc_id  = var.network_account_vpc_id
}

