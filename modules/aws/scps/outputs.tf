output "scp_ids" {
  description = "Map of SCP names to their IDs"
  value = {
    deny_public_s3 = aws_organizations_policy.deny_public_s3.id
  }
}

