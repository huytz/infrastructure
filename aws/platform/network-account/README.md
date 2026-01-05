# AWS Landing Zone Network Account

This module creates the foundational AWS infrastructure including VPC, subnets, networking components, and security groups following AWS best practices.

## Overview

The AWS Landing Zone Network Account provides:
- **VPC**: Virtual Private Cloud with proper CIDR allocation (`10.0.0.0/16`)
- **Multi-AZ Subnets**: Public and private subnets across multiple availability zones
- **Internet Gateway**: **Shared** internet gateway for all workload accounts
- **NAT Gateways**: **Shared** high-availability NAT Gateways for all workload accounts (one per AZ)
- **Transit Gateway**: Centralized network hub for multi-account connectivity
- **Route Tables**: Proper routing for public and private subnets
- **Security Groups**: Pre-configured security groups for different tiers
- **VPC Flow Logs**: Network traffic logging to CloudWatch

**Key Principles**:
- **Centralized Internet Access**: Internet Gateway and NAT Gateways are **only** in this account
- **Shared Services**: All workload accounts route internet traffic through this account's NAT Gateways
- **Network Hub**: All network functions (Transit Gateway, routing, etc.) are managed here
- **Cost Optimization**: Shared NAT Gateways reduce costs vs. per-account NAT Gateways

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.5.7)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with necessary permissions

## Setup

### 1. Configure AWS Credentials

Set up AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"

# Option 3: AWS SSO
aws sso login --profile your-profile
```

### 2. Set Environment Variables

```bash
export AWS_REGION="us-east-1"  # Optional, defaults to us-east-1
```

### 3. Deploy Network Account Infrastructure

```bash
cd aws/platform/network-account
terragrunt plan    # Preview changes
terragrunt apply   # Apply changes
```

## Architecture

### Network Topology

```
Internet
    |
Internet Gateway
    |
    ├── Public Subnet (AZ-a) ──> NAT Gateway ──> Private Subnet (AZ-a)
    ├── Public Subnet (AZ-b) ──> NAT Gateway ──> Private Subnet (AZ-b)
    └── Public Subnet (AZ-c) ──> NAT Gateway ──> Private Subnet (AZ-c)
```

### Components

1. **VPC** (`10.0.0.0/16`)
   - DNS hostnames enabled
   - DNS support enabled
   - VPC Flow Logs enabled

2. **Public Subnets** (one per AZ)
   - Internet-facing resources
   - Auto-assign public IP enabled
   - Route to Internet Gateway

3. **Private Subnets** (one per AZ)
   - Application and data resources
   - Route to NAT Gateway
   - No direct internet access

4. **NAT Gateways**
   - One per availability zone
   - High availability
   - Elastic IP addresses

5. **Security Groups**
   - Default: VPC-wide communication
   - Public: Web traffic (HTTP/HTTPS)
   - Private: Application tier access

## Dynamic CIDR Planning System

This system automatically generates subnet configurations for multiple environments using a dynamic, scalable approach that follows AWS best practices. Resources are deployed across multiple availability zones for high availability.

### Environment Definitions

The network account uses an environment-based subnet generation system:

```hcl
environments = {
  sre-account = {
    description = "SRE Account Environment"
    cidr_base   = "10.0"
  }
  # Add new environments here following the same pattern
}
```

### Availability Zones

The system automatically selects availability zones based on the AWS region:
- **us-east-1**: us-east-1a, us-east-1b, us-east-1c
- **us-west-2**: us-west-2a, us-west-2b, us-west-2c
- **eu-west-1**: eu-west-1a, eu-west-1b, eu-west-1c
- **Other regions**: Automatically generates AZ names based on region

### CIDR Calculation Logic

#### VPC CIDR Block
- **Base CIDR**: `10.0.0.0/16` (65,536 IP addresses)
- This provides sufficient address space for multiple environments

#### Public Subnets
- **Formula**: `${cidr_base}.${idx + 1}.0/24` per availability zone
- **Example**: For `cidr_base = "10.0"`:
  - AZ 1: `10.0.1.0/24` (256 IPs)
  - AZ 2: `10.0.2.0/24` (256 IPs)
  - AZ 3: `10.0.3.0/24` (256 IPs)
- **Purpose**: Internet-facing resources (load balancers, NAT gateways)

#### Private Subnets
- **Formula**: `${cidr_base}.${idx + 10}.0/24` per availability zone
- **Example**: For `cidr_base = "10.0"`:
  - AZ 1: `10.0.10.0/24` (256 IPs)
  - AZ 2: `10.0.11.0/24` (256 IPs)
  - AZ 3: `10.0.12.0/24` (256 IPs)
- **Purpose**: Application servers, databases, internal services

### Generated CIDR Ranges

#### VPC
| Component | CIDR Range | IP Count | Description |
|-----------|------------|----------|-------------|
| VPC | 10.0.0.0/16 | 65,536 | Main VPC CIDR block |

#### Public Subnets (sre-account)
| Subnet Name | CIDR Range | AZ | IP Count | Purpose |
|-------------|------------|----|----------|---------|
| sre-account-public-a | 10.0.1.0/24 | us-east-1a | 256 | Public resources AZ 1 |
| sre-account-public-b | 10.0.2.0/24 | us-east-1b | 256 | Public resources AZ 2 |
| sre-account-public-c | 10.0.3.0/24 | us-east-1c | 256 | Public resources AZ 3 |

#### Private Subnets (sre-account)
| Subnet Name | CIDR Range | AZ | IP Count | Purpose |
|-------------|------------|----|----------|---------|
| sre-account-private-a | 10.0.10.0/24 | us-east-1a | 256 | Private resources AZ 1 |
| sre-account-private-b | 10.0.11.0/24 | us-east-1b | 256 | Private resources AZ 2 |
| sre-account-private-c | 10.0.12.0/24 | us-east-1c | 256 | Private resources AZ 3 |

### Adding New Environments

To add a new environment to the network account:

1. **Update Locals**: Add the new environment to the `environments` map in `aws/platform/network-account/locals.tf`

```hcl
environments = {
  sre-account = {
    description = "SRE Account Environment"
    cidr_base   = "10.0"
  }
  production = {
    description = "Production Environment"
    cidr_base   = "10.1"
  }
}
```

This will automatically generate:
- **Public subnets**: `10.1.1.0/24`, `10.1.2.0/24`, `10.1.3.0/24`
- **Private subnets**: `10.1.10.0/24`, `10.1.11.0/24`, `10.1.12.0/24`

2. **Deploy**: Run `terragrunt apply` to create the new subnets

**Note**: For workload accounts (like SRE account), use the `modules/aws/workload-account` module instead. Each workload account gets its own VPC with a unique CIDR block (e.g., `10.1.0.0/16`, `10.2.0.0/16`).

### CIDR Best Practices

1. **CIDR Planning**: Ensure CIDR bases don't overlap between environments
2. **Multi-AZ**: Always deploy resources across multiple availability zones
3. **Subnet Sizing**: Use `/24` subnets (256 IPs) for proper sizing
4. **Reserve Space**: Reserve CIDR ranges for future growth
5. **Documentation**: Document CIDR allocation for all accounts

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region to deploy resources | `us-east-1` | No |
| `environment` | Environment name | `network-account` | No |
| `enable_dns_hostnames` | Enable DNS hostnames in VPC | `true` | No |
| `enable_dns_support` | Enable DNS support in VPC | `true` | No |
| `enable_flow_logs` | Enable VPC Flow Logs | `true` | No |
| `flow_logs_retention_days` | VPC Flow Logs retention in days | `7` | No |

### Outputs

The module provides comprehensive outputs:

- `vpc_id`: VPC ID
- `vpc_cidr_block`: VPC CIDR block
- `public_subnet_ids`: Map of public subnet IDs
- `private_subnet_ids`: Map of private subnet IDs
- `nat_gateway_ids`: Map of NAT Gateway IDs
- `security_group_ids`: Map of security group IDs
- `subnet_configurations`: Complete subnet configurations by environment

## Usage Example

### Deploy Network Account

```bash
cd aws/platform/network-account
terragrunt apply
```

### Use Outputs in Other Modules

```hcl
# In another Terragrunt module
dependency "network_account" {
  config_path = "../network-account"
}

inputs = {
  vpc_id            = dependency.network_account.outputs.vpc_id
  public_subnet_ids = dependency.network_account.outputs.public_subnet_ids
  # ... other outputs
}
```


## Cost Considerations

### NAT Gateways
- NAT Gateways are charged per hour and per GB of data processed
- One NAT Gateway per AZ provides high availability but increases cost
- Consider using a single NAT Gateway for non-production environments

### VPC Flow Logs
- CloudWatch Logs charges apply for log storage and ingestion
- Retention period affects storage costs
- Consider adjusting retention based on compliance requirements

## Security Best Practices

1. **Security Groups**: Review and customize security group rules based on your needs
2. **Network ACLs**: Consider adding network ACLs for additional layer of security
3. **VPC Endpoints**: Use VPC endpoints for AWS services to avoid internet routing
4. **Flow Logs**: Monitor Flow Logs for security incidents
5. **Least Privilege**: Apply least privilege principle to all security group rules

## Dependencies

- AWS Provider >= 5.0.0
- Terraform >= 1.5.7
- Terragrunt (latest)

## Related Documentation

### Official AWS Landing Zone Documentation
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html) - Official AWS guidance for building landing zones

### AWS Service Documentation
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Flow Logs Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)

### Related Modules
- [Workload Account Module](../../modules/aws/workload-account/README.md) - Reusable module for creating workload accounts

