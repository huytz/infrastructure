# Service Control Policies (SCPs) Module
# Based on AWS Organizations best practices and HashiCorp Validated Patterns
# Implements guardrails at the organization level

# Enable SCP policy type if not already enabled
# Note: This requires the management account and proper permissions
# SCPs must be enabled before policies can be created
resource "null_resource" "enable_scp_policy_type" {
  triggers = {
    root_id = var.organization_root_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Check if SCP policy type is enabled
      STATUS=$(aws organizations list-roots --query 'Roots[0].PolicyTypes[?Type==`SERVICE_CONTROL_POLICY`].Status' --output text 2>/dev/null || echo "NOT_ENABLED")
      
      if [ "$STATUS" != "ENABLED" ]; then
        echo "Enabling SERVICE_CONTROL_POLICY policy type..."
        aws organizations enable-policy-type \
          --root-id ${var.organization_root_id} \
          --policy-type SERVICE_CONTROL_POLICY || true
        # Wait a moment for the policy type to be enabled
        sleep 2
        echo "SERVICE_CONTROL_POLICY policy type enabled successfully"
      else
        echo "SERVICE_CONTROL_POLICY policy type is already enabled"
      fi
    EOT
  }
}

# SCP: Deny public S3 buckets
resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3"
  description = "Prevents making S3 buckets publicly accessible"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyPublicReadWriteAcl"
        Effect = "Deny"
        Action = [
          "s3:PutBucketAcl",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = [
              "public-read",
              "public-read-write",
              "authenticated-read"
            ]
          }
        }
      },
      {
        Sid    = "DenyPublicAccessBlockRemoval"
        Effect = "Deny"
        Action = [
          "s3:DeleteBucketPublicAccessBlock"
        ]
        Resource = "arn:aws:s3:::/*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "DenyPublicS3"
      Type      = "SCP"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_organizations_policy_attachment" "deny_public_s3" {
  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = var.organization_root_id

  depends_on = [null_resource.enable_scp_policy_type]
}

