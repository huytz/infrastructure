# Infrastructure as Code with Terragrunt

Multi-cloud infrastructure using Terraform and Terragrunt:
- **GCP**: Multi-project infrastructure with Shared VPC
- **AWS**: Complete Landing Zone architecture with Platform Landing Zone (PLZ) and Workload Landing Zone (WLZ)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [AWS CLI](https://aws.amazon.com/cli/) (for AWS)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (for GCP)

## Quick Start

### 1. Set Environment Variables

#### AWS Credentials
```bash
export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"  # Optional, for temporary credentials
```

#### GCP Credentials
```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export GOOGLE_CREDENTIALS='{"type":"service_account",...}'  # Or use GOOGLE_APPLICATION_CREDENTIALS
export BILLING_ACCOUNT_ID="your-billing-account-id"
export ORGANIZATION_ID="your-organization-id"
```

### 2. Deploy Infrastructure

```bash
# Preview changes
terragrunt run-all plan

# Apply changes
terragrunt run-all apply
```

**Deployment Order:**
- **AWS**: Organizations → Logging Account → Security Account → Network Account → Management Account → Workload Accounts
- **GCP**: Foundation → SRE Team → GKE

## Project Structure

```
infrastructure/
├── root.hcl                    # Root Terragrunt configuration
├── gcp/
│   ├── foundation/             # Foundation project (Shared VPC)
│   └── sre-team/               # SRE Team project
│       └── gke/                # GKE cluster
└── aws/
    ├── platform/               # Platform Landing Zone (PLZ)
    │   ├── management-account/ # Organizations, SCPs, Security Controls
    │   ├── security-account/   # GuardDuty, Security Hub Admin
    │   ├── logging-account/    # Centralized Logs (CloudTrail, Config)
    │   └── network-account/    # Network hub (Transit Gateway)
    ├── workloads/              # Workload Landing Zone (WLZ)
    │   └── sre-account/        # Workload account
    └── organizations/          # AWS Organizations structure
```

## Architecture Comparison: AWS vs GCP

This infrastructure follows the official landing zone best practices from both cloud providers. For detailed guidance, refer to:
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html)
- [GCP Landing Zone Guide](https://docs.cloud.google.com/architecture/landing-zones)

### Overview

| Aspect | AWS | GCP |
|--------|-----|-----|
| **Isolation Unit** | AWS Account | GCP Project |
| **Network Model** | VPC per Account | Shared VPC (Host/Service Projects) |
| **Connectivity** | Transit Gateway | Shared VPC Network |
| **Internet Gateway** | Centralized in Network Account | Cloud NAT (in Foundation) |
| **DNS** | Route53 Private Hosted Zones | Cloud DNS (centralized in foundation) |
| **Billing** | Per Account | Per Project |

### AWS Architecture

**Platform Landing Zone (PLZ)** - Foundational Infrastructure:
```
Management Account
├── AWS Organizations
├── Service Control Policies (SCPs)
└── Security Controls (CloudTrail, GuardDuty, Config, Security Hub)

Security Account
├── GuardDuty Admin
└── Security Hub Admin

Logging Account
├── CloudTrail Logs (S3)
├── Config Logs (S3)
└── VPC Flow Logs (CloudWatch)

Network Account (10.0.0.0/16) - Hub
├── VPC with Public & Private Subnets
├── Internet Gateway (IGW)
├── NAT Gateways (one per AZ)
├── Transit Gateway (Central Hub)
└── Route53 Private Zone (network.internal)
```

**Workload Landing Zone (WLZ)** - Application Accounts:
```
Workload Accounts (10.1.0.0/16, 10.2.0.0/16, ...) - Spokes
├── VPC with Private Subnets ONLY
├── Transit Gateway Attachment
├── Routes: 0.0.0.0/0 → Transit Gateway → Network Account NAT
└── Route53 Private Zone (account.internal)
```

**Key Characteristics:**
- **Platform Accounts**: Management, Security, Logging, Network (foundational services)
- **Workload Accounts**: Application-specific accounts (Dev, Test, Prod)
- Separate VPCs per account with isolated CIDR blocks
- Transit Gateway as central hub connecting all VPCs
- Centralized internet access (only network account has IGW/NAT)
- Workload accounts have NO public subnets or internet gateways
- Organization-wide security controls (CloudTrail, GuardDuty, Config, Security Hub)
- Service Control Policies (SCPs) enforce guardrails across all accounts

### GCP Architecture

```
Foundation Project (Host Project)
├── Shared VPC Network
├── Subnets (with secondary ranges for GKE)
├── Cloud NAT (for internet access)
└── Cloud DNS Private Zone (foundation.internal - centralized)

Workload Projects (Service Projects)
├── No VPC (uses Shared VPC)
├── Shared VPC Attachment
├── Resources use foundation's network
└── Access to foundation's Cloud DNS (automatic via Shared VPC)
```

**Key Characteristics:**
- Single Shared VPC network shared across multiple projects
- Host/Service model: Foundation = Host, Workload = Service projects
- Direct network sharing via Shared VPC (no Transit Gateway)
- All network resources centralized in foundation project

### Connectivity Patterns

#### AWS: Transit Gateway

**How it works:**
1. Network account creates Transit Gateway
2. Each workload account attaches VPC to Transit Gateway
3. Route tables configured to route traffic via Transit Gateway
4. Internet traffic routes: Workload → Transit Gateway → Network Account NAT → Internet

**Benefits:**
- ✅ True account isolation (separate VPCs)
- ✅ Centralized internet access
- ✅ Hub-and-spoke topology
- ✅ Cross-account routing via Transit Gateway

**Challenges:**
- ⚠️ Transit Gateway costs (data processing, attachments)
- ⚠️ More complex routing configuration
- ⚠️ Requires route table management

#### GCP: Shared VPC

**How it works:**
1. Foundation project creates Shared VPC network
2. Workload projects attach as service projects
3. Resources in service projects use foundation's network
4. Internet access via Cloud NAT in foundation project
5. Cloud DNS automatically shared via Shared VPC

**Benefits:**
- ✅ Simpler architecture (no Transit Gateway needed)
- ✅ Lower cost (no Transit Gateway charges)
- ✅ Direct network sharing
- ✅ Easier to manage (single network)
- ✅ Automatic DNS sharing

**Challenges:**
- ⚠️ Less isolation (shared network)
- ⚠️ Network changes affect all projects
- ⚠️ Requires careful subnet planning

### Internet Access

#### AWS
```
Internet → Internet Gateway (Network Account) → Public Subnets → 
NAT Gateways → Transit Gateway → Workload Account VPCs → Private Subnets
```

**Pattern:**
- Network account: Public subnets + NAT Gateways
- Workload accounts: Private subnets only
- All internet traffic routes through Transit Gateway

#### GCP
```
Internet → Cloud NAT (Foundation Project) → Shared VPC Network → Service Project Resources
```

**Pattern:**
- Foundation project: Cloud NAT for internet access
- Workload projects: No NAT needed (use foundation's NAT)
- Direct network access (no Transit Gateway)

### DNS Management

#### AWS: Route53 Private Hosted Zones

- **Network Account**: Centralized zone `network.internal`
- **Workload Accounts**: Account-specific zones `{account-name}.internal`
- **Cross-Account DNS**: Requires `aws_route53_zone_association` resource and IAM permissions

#### GCP: Cloud DNS

- **Foundation Project**: Centralized private DNS zone `foundation.internal`
- **Workload Projects**: Automatically have access via Shared VPC
- **Cross-Project DNS**: Automatic via Shared VPC, no additional configuration needed

### Cost Considerations

#### AWS
- Transit Gateway: $0.02/GB data processing + ~$36/month per attachment
- NAT Gateway: ~$32/month per NAT Gateway + $0.045/GB data processing
- Cost scales with number of accounts

#### GCP
- Shared VPC: No additional cost for attachment
- Cloud NAT: ~$45/month per NAT gateway + $0.045/GB data processing
- Lower cost for many projects (no Transit Gateway)

### When to Use Which?

#### Choose AWS Architecture If:
- ✅ Need strict account-level isolation
- ✅ Compliance requires separate accounts
- ✅ Need separate billing per account
- ✅ Complex routing requirements
- ✅ Multi-region connectivity needed

#### Choose GCP Architecture If:
- ✅ Simpler architecture preferred
- ✅ Cost optimization important
- ✅ Project-level isolation sufficient
- ✅ Shared network acceptable
- ✅ Easier management preferred

## AWS Landing Zone Details

### Platform Landing Zone (PLZ)

The Platform Landing Zone provides foundational infrastructure and governance:

- **Management Account**: AWS Organizations, SCPs, centralized security controls
- **Security Account**: GuardDuty and Security Hub admin account
- **Logging Account**: Centralized logging for CloudTrail, Config, and VPC Flow Logs
- **Network Account**: Transit Gateway hub, shared Internet Gateway and NAT Gateways

### Workload Landing Zone (WLZ)

Workload accounts inherit security controls and networking from the PLZ:

- **SRE Account**: Development workload account
- Future accounts can be added (e.g., production, staging)

### Security & Governance

- **Service Control Policies (SCPs)**: Organization-wide guardrails
  - Prevent leaving organization
  - Require MFA
  - Prevent disabling security services
  - Restrict regions
  - Enforce IAM roles only
  - Require S3 encryption

- **Security Controls**: Organization-wide security services
  - CloudTrail (audit logging)
  - GuardDuty (threat detection)
  - AWS Config (compliance monitoring)
  - Security Hub (security findings aggregation)

For detailed AWS Landing Zone documentation, see [`aws/README.md`](aws/README.md).

## Additional Resources

### Official Landing Zone Documentation
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html) - Official AWS guidance for building landing zones
- [HashiCorp Validated Patterns: AWS Landing Zone](https://developer.hashicorp.com/validated-patterns/terraform/build-aws-lz-with-terraform) - HashiCorp's validated approach
- [GCP Landing Zone Guide](https://docs.cloud.google.com/architecture/landing-zones) - Official GCP landing zone architecture documentation

### Terraform & Tools
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Cloud-Specific Documentation
- [AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/)
- [GCP Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc)

## License

MIT License
