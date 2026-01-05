# AWS Workload Account Module

Reusable Terraform module for creating AWS workload accounts connected to a centralized network account via Transit Gateway.

## Core Components

- **VPC**: Private VPC with configurable CIDR block
- **Private Subnets**: Multi-AZ private subnets (no public subnets)
- **Transit Gateway Attachment**: Connects to Transit Gateway in network account
- **Internet Access**: Routes via Transit Gateway to network account's shared NAT Gateway
- **Security Groups**: Pre-configured with cross-account access rules
- **IAM Roles**: Cross-account access roles
- **VPC Flow Logs**: Network traffic logging to CloudWatch

## Key Principles

- No Internet Gateway or NAT Gateways (only in network account)
- All subnets are private
- Internet traffic routes through Transit Gateway

## Usage

### Basic Example

```hcl
module "workload_account" {
  source = "../../modules/aws/workload-account"

  account_name              = "production"
  vpc_cidr                 = "10.2.0.0/16"
  network_account_vpc_id    = var.network_account_vpc_id
  network_account_vpc_cidr  = var.network_account_vpc_cidr
  transit_gateway_id       = var.transit_gateway_id
}
```

### Terragrunt Example

```hcl
dependency "network_account" {
  config_path = "../network-account"
}

terraform {
  source = "../../modules/aws/workload-account"
}

inputs = {
  account_name              = "production"
  vpc_cidr                 = "10.2.0.0/16"
  network_account_vpc_id    = dependency.network_account.outputs.vpc_id
  network_account_vpc_cidr  = dependency.network_account.outputs.vpc_cidr_block
  transit_gateway_id       = dependency.network_account.outputs.transit_gateway_id
}
```

## Inputs

| Name | Description | Required |
|------|-------------|:--------:|
| `account_name` | Name of the workload account | Yes |
| `vpc_cidr` | CIDR block for VPC (e.g., 10.2.0.0/16) | Yes |
| `network_account_vpc_id` | VPC ID from network account | Yes |
| `network_account_vpc_cidr` | VPC CIDR from network account | Yes |
| `transit_gateway_id` | Transit Gateway ID from network account | Yes |
| `aws_region` | AWS region | No (default: us-east-1) |
| `enable_flow_logs` | Enable VPC Flow Logs | No (default: true) |
| `subnet_count` | Number of subnets per AZ | No (default: 3) |
| `tags` | Additional tags | No |

## Outputs

- `vpc_id` - VPC ID
- `private_subnet_ids` - List of private subnet IDs
- `security_group_ids` - Map of security group IDs
- `transit_gateway_attachment_id` - Transit Gateway attachment ID

## Dependencies

- Network account must be deployed first
- Transit Gateway must exist in network account

## CIDR Recommendations

- Network Account: `10.0.0.0/16`
- SRE Account: `10.1.0.0/16`
- Production: `10.2.0.0/16`
- Staging: `10.3.0.0/16`

## Related Documentation

### Official AWS Landing Zone Documentation
- [AWS Landing Zone Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/building-landing-zones.html) - Official AWS guidance for building landing zones

### AWS Service Documentation
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
