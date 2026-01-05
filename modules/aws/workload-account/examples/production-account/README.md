# Production Account Example

Example usage of the workload-account module for a production account.

## Usage

```hcl
module "production_account" {
  source = "../../.."

  account_name              = "production"
  vpc_cidr                 = "10.2.0.0/16"
  network_account_vpc_id    = var.network_account_vpc_id
  network_account_vpc_cidr  = var.network_account_vpc_cidr
  transit_gateway_id       = var.transit_gateway_id
  
  tags = {
    Environment = "production"
    Team        = "Platform"
  }
}
```

## Prerequisites

- Network account must be deployed first
- Provide network account VPC ID, CIDR, and Transit Gateway ID
