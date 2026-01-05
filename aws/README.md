# AWS Landing Zone

Complete AWS Landing Zone implementation following [HashiCorp Validated Patterns](https://developer.hashicorp.com/validated-patterns/terraform/build-aws-lz-with-terraform) and [AWS Organizations best practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html).

## Architecture Overview

This landing zone implements a **Platform Landing Zone (PLZ)** and **Workload Landing Zone (WLZ)** architecture:

```
AWS Organization (Root)
│
├── Platform OU
│   ├── Management Account (this account)
│   ├── Security Account
│   ├── Network Account
│   └── Logging Account
│
└── Workloads OU
    ├── Dev OU
    │   └── SRE Account (Dev)
    ├── Sandbox OU
    │   └── (Future sandbox accounts)
    └── Prod OU
        └── (Future production accounts)
```

## Components

### Platform Landing Zone (PLZ)

**Management Account** (`platform/management-account/`)
- AWS Organizations management
- Service Control Policies (SCPs)
- Centralized CloudTrail organization trail
- AWS IAM Identity Center (AWS SSO) configuration

**Security Account** (`platform/security-account/`)
- Security Hub admin account and organization configuration
- IAM admin user for console access
- Security admin role for cross-account access

**Network Account** (`platform/network-account/`)
- Hub VPC with Transit Gateway
- Shared Internet Gateway and NAT Gateways
- Centralized networking for all workload accounts

**Logging Account** (`platform/logging-account/`)
- Centralized CloudTrail logs (S3)
- VPC Flow Logs (CloudWatch Logs)

### Workload Landing Zone (WLZ)

**SRE Account** (`workloads/sre-account/`)
- Workload VPC connected via Transit Gateway
- Application-specific resources
- Inherits security controls from PLZ

## Design Principles

Based on HashiCorp Validated Patterns and AWS Well-Architected Framework:

1. **Infrastructure as Code**: All resources managed via Terraform/Terragrunt
2. **Separation of Concerns**: PLZ vs WLZ separation
3. **Policy as Code**: AWS SCPs for organization-wide guardrails
4. **Least Privilege**: IAM roles with minimal permissions
5. **Centralized Security**: CloudTrail organization trail, Security Hub
6. **Hub-and-Spoke Networking**: Transit Gateway architecture
7. **Centralized Access Management**: AWS IAM Identity Center (AWS SSO)

## Prerequisites

1. **Management Account**: AWS account with Organizations permissions
2. **Terraform** >= 1.5.7
3. **Terragrunt** latest
4. **AWS CLI** configured
5. **Account IDs**: Network, Security, Logging, SRE account IDs

## Deployment Order

### Phase 1: Organizations Structure

```bash
# 1. Set organization name
export AWS_ORGANIZATION_NAME="MyCompany"

# 2. Set account IDs (if accounts already exist)
export NETWORK_ACCOUNT_ID="123456789012"
export SECURITY_ACCOUNT_ID="123456789013"
export LOGGING_ACCOUNT_ID="123456789014"
export SRE_ACCOUNT_ID="123456789015"

# 3. Deploy Organizations structure
cd aws/organizations
terragrunt apply
```

### Phase 2: Logging Account

```bash
# 1. Set bucket name (optional, will auto-generate)
export CLOUDTRAIL_LOG_BUCKET_NAME="cloudtrail-logs-123456789014"

# 2. Deploy logging account
cd aws/platform/logging-account
terragrunt apply
```

### Phase 3: Security Account

```bash
# 1. Set management account ID
export MANAGEMENT_ACCOUNT_ID="123456789011"

# 2. Deploy security account
cd aws/platform/security-account
terragrunt apply
```

### Phase 4: Network Account

```bash
# Deploy network account (already exists)
cd aws/platform/network-account
terragrunt apply
```

### Phase 5: Management Account (SCPs and CloudTrail)

```bash
# 1. Set bucket name (optional, will auto-generate)
export CLOUDTRAIL_LOG_BUCKET_NAME="cloudtrail-logs-123456789014"

# 2. Deploy management account (SCPs and CloudTrail)
cd aws/platform/management-account
terragrunt apply
```

**Note**: After deploying the management account, deploy the security account again to configure Security Hub organization settings (the security account must be designated as admin first).

### Phase 6: Workload Accounts

```bash
# Deploy SRE account (already exists)
cd aws/workloads/sre-account
terragrunt apply
```

### Adding New Workload Accounts

To add a new workload account and connect it to the network:

1. **Create account directory** and copy structure from `sre-account`
2. **Configure account** in `terragrunt.hcl`:
   - Set unique VPC CIDR (e.g., `10.5.0.0/16`)
   - Choose route table based on environment:
     - Development: `transit_gateway_route_table_id_development`
     - Sandbox: `transit_gateway_route_table_id_sandbox`
     - Production: `transit_gateway_route_table_id_production`
   - Set `environment_type` to match route table choice
3. **Add to organizations** (`aws/organizations/terragrunt.hcl`):
   ```hcl
   account_ou_mapping = {
     # ... existing accounts
     new-account = "workloads/dev"  # or "workloads/sandbox" or "workloads/prod"
   }
   ```
4. **Add to network account** (`aws/platform/network-account/terragrunt.hcl`):
   ```hcl
   workload_environments = {
     # ... existing accounts
     new-account = {
       vpc_cidr    = "10.5.0.0/16"
       environment = "development"  # or "sandbox" or "production"
     }
   }
   ```
5. **Deploy**:
   ```bash
   cd aws/organizations && terragrunt apply  # Create account
   cd ../platform/network-account && terragrunt apply  # Update routes
   cd ../../workloads/new-account && terragrunt apply  # Deploy infrastructure
   ```

See `aws/workloads/README.md` for detailed step-by-step instructions.

## Service Control Policies (SCPs)

The following SCP is deployed at the organization root:

1. **DenyPublicS3**: Prevents making S3 buckets publicly accessible
   - Denies `s3:PutBucketAcl` and `s3:PutObjectAcl` with public ACLs
   - Denies `s3:DeleteBucketPublicAccessBlock` to prevent removal of public access blocking

**Note**: SCPs must be enabled in the AWS Organization before they can be attached. The module automatically enables the SERVICE_CONTROL_POLICY type if not already enabled.

## Security Controls

### CloudTrail
- Organization-wide trail
- Multi-region logging
- Includes global service events
- Logs stored in logging account S3 bucket
- Managed from management account

### Security Hub
- Organization-wide hub
- Security account as admin account
- Auto-enabled for all organization accounts
- Auto-enables default security standards
- Managed from security account (after admin designation)

### AWS IAM Identity Center (AWS SSO)
- Centralized access management via `awsapps.com` portal
- Permission sets: AdministratorAccess, ReadOnlyAccess, SecurityAudit
- Session duration: 1 hour
- Managed from management account

## Networking Architecture

**Hub-and-Spoke Model**:
- **Hub**: Network Account (Transit Gateway, Internet Gateway, NAT Gateways)
- **Spokes**: Workload Accounts (VPCs connected via Transit Gateway)

**Key Principles**:
- No Internet Gateways in workload accounts
- No NAT Gateways in workload accounts
- All internet traffic routes through network account
- Cross-account communication via Transit Gateway

## Account Invitation Process

If accounts already exist, they must be invited to the organization:

```bash
# From management account
aws organizations invite-account-to-organization \
  --target Id=NETWORK_ACCOUNT_ID,Type=ACCOUNT

aws organizations invite-account-to-organization \
  --target Id=SECURITY_ACCOUNT_ID,Type=ACCOUNT

aws organizations invite-account-to-organization \
  --target Id=LOGGING_ACCOUNT_ID,Type=ACCOUNT

aws organizations invite-account-to-organization \
  --target Id=SRE_ACCOUNT_ID,Type=ACCOUNT
```

Then accept invitations from each member account and move them to appropriate OUs.

## Configuration

All common configuration values are centralized in `aws/root.hcl` and can be accessed by child Terragrunt configurations via `read_terragrunt_config`.

### Environment Variables

Set these environment variables before deploying. All values are read by `aws/root.hcl` and made available to child configurations:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AWS_REGION` | AWS region | No | `us-east-1` |
| `AWS_ORGANIZATION_NAME` | Organization name | No | `MyOrganization` |
| `MANAGEMENT_ACCOUNT_ID` | Management account ID | Yes (for security account) | - |
| `NETWORK_ACCOUNT_ID` | Network account ID | Yes (if account exists) | - |
| `SECURITY_ACCOUNT_ID` | Security account ID | Yes (if account exists) | - |
| `LOGGING_ACCOUNT_ID` | Logging account ID | Yes (if account exists) | - |
| `SRE_ACCOUNT_ID` | SRE account ID | Yes (if account exists) | - |
| `IAC_EXECUTION_ACCOUNT_ID` | IaC execution account ID | No | Management account ID |
| `CLOUDTRAIL_LOG_BUCKET_NAME` | CloudTrail S3 bucket name | No | Auto-generated as `{organization_name}-cloudtrail-log` |

### Accessing Configuration in Child Configurations

Child Terragrunt configurations automatically access these values from `aws/root.hcl`:

```hcl
locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

inputs = {
  aws_region = local.root_config.locals.aws_region
  cloudtrail_log_bucket_name = local.root_config.locals.cloudtrail_log_bucket_name
  iac_execution_account_id = local.root_config.locals.iac_execution_account_id
  # ... etc
}
```

This centralizes configuration management and ensures consistency across all accounts.

## Troubleshooting

### Organization Already Exists
If AWS Organizations already exists, Terraform will use the existing organization. This is expected behavior.

### Account Not Found
Ensure accounts are invited to the organization before deploying. Use `aws organizations list-accounts` to verify.

### SCP Errors
SCPs are applied at the root level. Check SCP attachments with:
```bash
aws organizations list-policies-for-target --target-id ROOT_ID --filter SERVICE_CONTROL_POLICY
```

**Note**: If you see `PolicyTypeNotEnabledException`, the SCP policy type must be enabled first. The module automatically enables it, but you can also enable it manually:
```bash
aws organizations enable-policy-type --root-id ROOT_ID --policy-type SERVICE_CONTROL_POLICY
```

### Security Hub Organization Configuration
Security Hub organization configuration must be managed from the admin account (security account). After the management account designates the security account as admin, deploy the security account to configure organization settings.

### IAM Identity Center Not Enabled
IAM Identity Center must be enabled via the AWS Console before Terraform can manage it:
1. Go to AWS Console → IAM Identity Center
2. Click "Enable"
3. Then run Terraform to configure permission sets

## References

- [HashiCorp Validated Patterns: AWS Landing Zone](https://developer.hashicorp.com/validated-patterns/terraform/build-aws-lz-with-terraform)
- [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/)
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/)

