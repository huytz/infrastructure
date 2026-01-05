# AWS Landing Zone SRE Account

This account uses the reusable `workload-account` module to create SRE account infrastructure connected to the network account via Transit Gateway, following AWS Landing Zone best practices for multi-account architecture.

**Note**: This account is implemented using the `modules/aws/workload-account` module. All infrastructure code is in the module, making it easy to create additional workload accounts.

## Overview

The SRE Account provides:
- **VPC**: Separate VPC for SRE workloads (`10.1.0.0/16`)
- **Private Subnets Only**: Private subnets across multiple availability zones (no public subnets)
- **Transit Gateway Attachment**: Attaches to Transit Gateway in network account for secure inter-account communication
- **Internet Access**: Routes internet traffic (`0.0.0.0/0`) via Transit Gateway to network account (shared NAT Gateway)
- **Security Groups**: Pre-configured security groups with cross-account access rules
- **IAM Roles**: Cross-account access roles for secure account communication
- **VPC Flow Logs**: Network traffic logging to CloudWatch

**Key Principles**:
- **No Internet Gateway**: Internet Gateway is only in network-account
- **No NAT Gateways**: NAT Gateways are only in network-account (shared)
- **All Subnets Private**: Workload accounts only have private subnets
- **Internet via Transit Gateway**: All internet traffic routes through Transit Gateway to network account's NAT Gateway

## Architecture

### Multi-Account Connectivity

```
Network Account (10.0.0.0/16)          SRE Account (10.1.0.0/16)
     │                                        │
     ├── VPC                                  ├── VPC
     │   ├── Public Subnets                   │   ├── Public Subnets
     │   └── Private Subnets                  │   └── Private Subnets
     │                                        │
     └── Transit Gateway Attachment          └── Transit Gateway Attachment
                    │                                    │
                    └──────── Transit Gateway ──────────┘
```

### Network Topology

```
Internet
    |
Internet Gateway (Network Account Only)
    |
    └── Public Subnets (Network Account)
            │
            └── NAT Gateways (Network Account - Shared)
                    │
                    └── Transit Gateway
                            │
                            └── SRE Account VPC Attachment
                                    │
                                    └── Private Subnets (SRE Account)
                                            │
                                            └── Routes: 0.0.0.0/0 → Transit Gateway → Network Account NAT
```

## Prerequisites

- Network account must be deployed first
- AWS credentials configured with appropriate permissions
- Transit Gateway created in network account

## Implementation

This account uses the reusable `modules/aws/workload-account` module. The configuration is defined in:
- `terragrunt.hcl` - Terragrunt configuration with dependencies and inputs
- `main.tf` - Calls the workload-account module
- `variables.tf` - Variable definitions (passed to module)
- `outputs.tf` - Output passthrough from module

All infrastructure resources (VPC, subnets, security groups, Transit Gateway attachment, IAM roles) are created by the module, ensuring consistency with other workload accounts.

### Module Benefits

- **Reusability**: Same module used for all workload accounts
- **Consistency**: All accounts follow identical architecture
- **Maintainability**: Update module once, affects all accounts
- **Fast Setup**: New accounts can be created in minutes
- **Best Practices**: Module enforces AWS Landing Zone patterns

## Setup

### 1. Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

### 2. Deploy Network Account First

```bash
cd aws/platform/network-account
terragrunt apply
```

### 3. Deploy SRE Account

```bash
cd aws/workloads/sre-account
terragrunt plan    # Preview changes
terragrunt apply   # Apply changes
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `account_name` | Name of the workload account | `sre` | No |
| `vpc_cidr` | CIDR block for SRE VPC | `10.1.0.0/16` | No |
| `aws_region` | AWS region to deploy resources | `us-east-1` | No |
| `environment` | Environment name | `sre-account` | No |
| `network_account_vpc_id` | VPC ID from network account | - | Yes (from dependency) |
| `network_account_vpc_cidr` | VPC CIDR from network account | - | Yes (from dependency) |
| `transit_gateway_id` | Transit Gateway ID from network account | - | Yes (from dependency) |
| `enable_flow_logs` | Enable VPC Flow Logs | `true` | No |
| `flow_logs_retention_days` | VPC Flow Logs retention days | `7` | No |
| `subnet_count` | Number of subnets per AZ | `3` | No |
| `subnet_cidr_offset` | CIDR offset for private subnets | `10` | No |
| `tags` | Additional tags | `{Team = "SRE"}` | No |

### Dependencies

The SRE account depends on the network account:
- VPC ID and CIDR block
- Transit Gateway ID (required - Transit Gateway must be created in network account first)

## Components

### 1. VPC (`10.1.0.0/16`)
   - Separate CIDR block from network account
   - DNS hostnames and support enabled
   - VPC Flow Logs enabled

### 2. Subnets (Private Only)
   - **Private Subnets**: `10.1.10.0/24`, `10.1.11.0/24`, `10.1.12.0/24` (one per AZ)
   - **No Public Subnets**: All internet access routes through Transit Gateway to network account

### 3. Transit Gateway Attachment
   - Attaches SRE account VPC to Transit Gateway in network account
   - Routes traffic between VPCs via Transit Gateway
   - Uses private subnets for attachment
   - **Note**: Transit Gateway itself is created and managed in network-account

### 4. Security Groups
   - **Default**: Allows traffic from both VPCs (network + SRE)
   - **Private**: Allows traffic from network account VPC and HTTP/HTTPS from network account
   - **Note**: No public security group (no public subnets)

### 5. IAM Roles
   - Cross-account access roles
   - Secure assume role policies

## Usage Example

### Deploy SRE Account

```bash
cd aws/workloads/sre-account
terragrunt apply
```

### Use Outputs in Other Modules

```hcl
# In another Terragrunt module
dependency "sre_account" {
  config_path = "../sre-account"
}

inputs = {
  vpc_id            = dependency.sre_account.outputs.vpc_id
  subnet_ids        = dependency.sre_account.outputs.private_subnet_ids
  transit_gateway_id = dependency.sre_account.outputs.transit_gateway_id
}
```

## Cross-Account Communication

### Transit Gateway Routing

Routes are automatically configured:
- **SRE Account → Network Account**: Routes via Transit Gateway
- **SRE Account → Internet (0.0.0.0/0)**: Routes via Transit Gateway to network account's NAT Gateway
- **Network Account → SRE Account**: Routes via Transit Gateway (configured in network account)

### Security Groups

Security groups allow traffic from:
- Same VPC CIDR
- Network account VPC CIDR (`10.0.0.0/16`)

### IAM Roles

Cross-account IAM roles enable:
- Network account to access SRE account resources
- SRE account to assume roles in network account

## Best Practices

1. **Separate Accounts**: Network and SRE accounts are isolated for security
2. **Centralized Internet Access**: Internet Gateway and NAT Gateways only in network account (shared)
3. **Private Subnets Only**: Workload accounts only have private subnets
4. **Transit Gateway**: Centralized connectivity management and internet routing
5. **Route Tables**: Separate route tables per AZ for high availability
6. **Security Groups**: Least privilege access between accounts
7. **Flow Logs**: Monitor all cross-account traffic
8. **Cost Optimization**: Shared NAT Gateways reduce costs vs. per-account NAT Gateways

## Cost Considerations

### Transit Gateway
- Data processing charges apply
- Attachment charges per hour
- Consider data transfer costs between accounts

### NAT Gateways
- One per AZ for high availability
- Consider single NAT Gateway for cost optimization in non-production

## Dependencies

- Network Account must be deployed first
- AWS Provider >= 5.0.0
- Terraform >= 1.5.7
- Terragrunt (latest)

## Related Documentation

### Official AWS Landing Zone Documentation
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html) - Official AWS guidance for building landing zones

### AWS Service Documentation
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [AWS Multi-Account Architecture](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/)

### Related Modules
- [Network Account README](../../platform/network-account/README.md)
- [Workload Account Module README](../../modules/aws/workload-account/README.md)

