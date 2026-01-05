# Workload Accounts

This directory contains workload account configurations for the AWS Landing Zone. Each workload account is isolated at the network level using separate Transit Gateway route tables.

## Architecture

### Network Isolation

Workload accounts are organized into three environments with **complete network isolation** via separate Transit Gateway route tables:

- **Development Environment**: SRE account uses the `development` Transit Gateway route table
- **Sandbox Environment**: Sandbox accounts use the `sandbox` Transit Gateway route table
- **Production Environment**: Production accounts use the `production` Transit Gateway route table
- **Isolation**: Accounts in different environments **cannot communicate** with each other directly
- **Shared Access**: All accounts can reach the network account (for internet access via NAT Gateway)

### Transit Gateway Route Tables

The Transit Gateway in the network account has four route tables:

1. **Development Route Table**: Used by development and SRE accounts
2. **Sandbox Route Table**: Used by sandbox/testing accounts
3. **Production Route Table**: Used by production accounts
4. **Network Route Table**: Used by the network account itself

### Network Flow

```
SRE Account VPC (10.1.0.0/16)
    ↓
Transit Gateway Attachment
    ↓
Development Route Table (isolated from sandbox & production)
    ↓
Network Account (10.0.0.0/16) → Internet via NAT Gateway

Sandbox Account VPC (10.4.0.0/16)
    ↓
Transit Gateway Attachment
    ↓
Sandbox Route Table (isolated from development & production)
    ↓
Network Account (10.0.0.0/16) → Internet via NAT Gateway

Production Account VPC (example)
    ↓
Transit Gateway Attachment
    ↓
Production Route Table (isolated from development & sandbox)
    ↓
Network Account (10.0.0.0/16) → Internet via NAT Gateway
```

**Key Points:**
- All three environment route tables are **completely isolated** - no cross-environment communication
- All environments share the same Transit Gateway but use different route tables
- Network account can reach all environments via VPC route tables
- Each account declares which route table to use via `transit_gateway_route_table_id` and `environment_type`

## Accounts

### SRE Account (`sre-account/`)
- **VPC CIDR**: `10.1.0.0/16`
- **Environment**: Development
- **Route Table**: Development route table
- **Purpose**: SRE/DevOps tooling and infrastructure

### Sandbox Account (optional)
- **VPC CIDR**: `10.4.0.0/16` (example)
- **Environment**: Sandbox
- **Route Table**: Sandbox route table
- **Purpose**: Testing and sandbox workloads

### Production Accounts (optional)
- **VPC CIDR**: Custom (example: `10.3.0.0/16`)
- **Environment**: Production
- **Route Table**: Production route table
- **Purpose**: Production workloads

## Deployment Order

1. **Network Account** (must be deployed first)
   - Creates Transit Gateway
   - Creates development, sandbox, and production route tables
   - Configures workload environment mappings

2. **Workload Accounts** (can be deployed in parallel)
   - Each account creates VPC attachment
   - Associates attachment with appropriate route table (development/sandbox/production)
   - Routes are automatically propagated

## Configuration

Each workload account requires:

- `transit_gateway_id`: From network account outputs
- `transit_gateway_route_table_id`: Development, sandbox, or production route table ID from network account
- `environment_type`: "development", "sandbox", or "production" (validated)
- `vpc_cidr`: Unique CIDR block per account

**Available Route Table Outputs from Network Account:**
- `transit_gateway_route_table_id_development` - For development accounts
- `transit_gateway_route_table_id_sandbox` - For sandbox accounts
- `transit_gateway_route_table_id_production` - For production accounts

## Best Practices

1. **Network Isolation**: Always use separate route tables for dev and prod
2. **CIDR Planning**: Ensure no CIDR overlap between accounts
3. **Route Propagation**: Let Transit Gateway handle route propagation automatically
4. **Security**: Use security groups and NACLs for additional isolation within environments
5. **Monitoring**: Enable VPC Flow Logs for all workload accounts

## Adding New Accounts

This guide walks you through adding a new workload account and connecting it to the network with the appropriate environment route table.

### Step-by-Step Guide

#### Step 1: Create Account Directory Structure

Create a new directory for your account and copy the structure from an existing account:

```bash
# Create new account directory
mkdir -p aws/workloads/my-new-account

# Copy files from existing account (e.g., sre-account)
cp aws/workloads/sre-account/*.tf aws/workloads/my-new-account/
cp aws/workloads/sre-account/terragrunt.hcl aws/workloads/my-new-account/
```

#### Step 2: Configure Account in Terragrunt

Edit `aws/workloads/my-new-account/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("aws/root.hcl")
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders("aws/root.hcl"))
}

dependency "network_account" {
  config_path = find_in_parent_folders("aws/platform/network-account")
  mock_outputs = {
    vpc_id                                = "vpc-mock123456"
    vpc_cidr_block                        = "10.0.0.0/16"
    public_subnet_ids                     = {}
    private_subnet_ids                    = {}
    security_group_ids                    = {}
    transit_gateway_id                    = "tgw-mock123456"
    # Choose the appropriate route table based on environment:
    # transit_gateway_route_table_id_development (for development)
    # transit_gateway_route_table_id_sandbox (for sandbox)
    # transit_gateway_route_table_id_production (for production)
    transit_gateway_route_table_id_development = "tgw-rtb-mock123456"
  }
}

inputs = {
  # Required: Account name (must match directory name)
  account_name = "my-new-account"
  
  # Required: Unique VPC CIDR block (must not overlap with other accounts)
  vpc_cidr = "10.5.0.0/16"  # Example: Use 10.5.0.0/16, 10.6.0.0/16, etc.
  
  # Required: Network account references
  network_account_vpc_id   = dependency.network_account.outputs.vpc_id
  network_account_vpc_cidr = dependency.network_account.outputs.vpc_cidr_block
  transit_gateway_id       = dependency.network_account.outputs.transit_gateway_id
  
  # Required: Choose route table based on environment
  # Option 1: Development environment
  transit_gateway_route_table_id = dependency.network_account.outputs.transit_gateway_route_table_id_development
  environment_type               = "development"
  
  # Option 2: Sandbox environment (uncomment to use)
  # transit_gateway_route_table_id = dependency.network_account.outputs.transit_gateway_route_table_id_sandbox
  # environment_type               = "sandbox"
  
  # Option 3: Production environment (uncomment to use)
  # transit_gateway_route_table_id = dependency.network_account.outputs.transit_gateway_route_table_id_production
  # environment_type               = "production"
  
  # Optional: Environment and region settings
  aws_region               = local.root_config.locals.aws_region
  environment              = "my-new-account"
  enable_flow_logs         = true
  flow_logs_retention_days = 7  # Increase for production (e.g., 30)
  
  # Required: IaC Execution Account ID
  iac_execution_account_id = local.root_config.locals.iac_execution_account_id
  
  # Optional: Custom tags
  tags = {
    Team = "MyTeam"
  }
}
```

**Key Configuration Points:**
- `account_name`: Must match your directory name
- `vpc_cidr`: Must be unique and not overlap with other accounts (check existing accounts)
- `transit_gateway_route_table_id`: Choose based on environment (development/sandbox/production)
- `environment_type`: Must match the route table choice ("development", "sandbox", or "production")

#### Step 3: Add Account to Organizations Configuration

Edit `aws/organizations/terragrunt.hcl` and add your account to `account_ou_mapping`:

```hcl
account_ou_mapping = {
  network = "platform"
  logging = "platform"
  sre     = "workloads/dev"
  my-new-account = "workloads/dev"  # Add this line
  # Choose OU based on environment:
  # "workloads/dev"     → development environment
  # "workloads/sandbox" → sandbox environment
  # "workloads/prod"    → production environment
}
```

**OU Mapping Guide:**
- `workloads/dev` → Development environment (uses development route table)
- `workloads/sandbox` → Sandbox environment (uses sandbox route table)
- `workloads/prod` → Production environment (uses production route table)

#### Step 4: Add Account to Network Account Configuration

Edit `aws/platform/network-account/terragrunt.hcl` and add your account to `workload_environments`:

```hcl
workload_environments = {
  sre = {
    vpc_cidr    = "10.1.0.0/16"
    environment = "development"
  }
  my-new-account = {  # Add this block
    vpc_cidr    = "10.5.0.0/16"  # Must match vpc_cidr in terragrunt.hcl
    environment = "development"  # Must match environment_type in terragrunt.hcl
  }
  sandbox = {
    vpc_cidr    = "10.4.0.0/16"
    environment = "sandbox"
  }
}
```

**Important:** The `vpc_cidr` and `environment` values must match exactly what you configured in Step 2.

#### Step 5: Deploy the Account

```bash
# 1. Deploy organizations (if account needs to be created)
cd aws/organizations
terragrunt apply

# 2. Deploy network account (to update route tables)
cd ../platform/network-account
terragrunt apply

# 3. Deploy the new workload account
cd ../../workloads/my-new-account
terragrunt apply
```

### Complete Example: Adding a Production Account

Here's a complete example for adding a production account named `prod-app`:

**1. Create directory and files:**
```bash
mkdir -p aws/workloads/prod-app
cp aws/workloads/sre-account/*.tf aws/workloads/prod-app/
cp aws/workloads/sre-account/terragrunt.hcl aws/workloads/prod-app/
```

**2. Configure `aws/workloads/prod-app/terragrunt.hcl`:**
```hcl
inputs = {
  account_name                    = "prod-app"
  vpc_cidr                        = "10.3.0.0/16"
  network_account_vpc_id          = dependency.network_account.outputs.vpc_id
  network_account_vpc_cidr        = dependency.network_account.outputs.vpc_cidr_block
  transit_gateway_id              = dependency.network_account.outputs.transit_gateway_id
  transit_gateway_route_table_id = dependency.network_account.outputs.transit_gateway_route_table_id_production
  environment_type               = "production"
  # ... other settings
}
```

**3. Add to `aws/organizations/terragrunt.hcl`:**
```hcl
account_ou_mapping = {
  # ... existing accounts
  prod-app = "workloads/prod"
}
```

**4. Add to `aws/platform/network-account/terragrunt.hcl`:**
```hcl
workload_environments = {
  # ... existing accounts
  prod-app = {
    vpc_cidr    = "10.3.0.0/16"
    environment = "production"
  }
}
```

### Environment Route Table Reference

| Environment | OU Path | Route Table Output | Environment Type |
|-------------|---------|-------------------|------------------|
| Development | `workloads/dev` | `transit_gateway_route_table_id_development` | `"development"` |
| Sandbox | `workloads/sandbox` | `transit_gateway_route_table_id_sandbox` | `"sandbox"` |
| Production | `workloads/prod` | `transit_gateway_route_table_id_production` | `"production"` |

### Verification Checklist

After adding a new account, verify:

- [ ] Account directory created with all required files
- [ ] `terragrunt.hcl` configured with correct route table and environment type
- [ ] Account added to `organizations/terragrunt.hcl` `account_ou_mapping`
- [ ] Account added to `network-account/terragrunt.hcl` `workload_environments`
- [ ] VPC CIDR is unique and doesn't overlap with other accounts
- [ ] Route table ID matches the environment type
- [ ] OU path matches the environment (dev/sandbox/prod)
- [ ] Organizations deployed (if creating new account)
- [ ] Network account deployed (to update route tables)
- [ ] Workload account deployed successfully

## Troubleshooting

### Accounts Cannot Communicate

- **Check route table association**: Ensure accounts are associated with correct route tables
- **Verify route propagation**: Check Transit Gateway route table propagations
- **Check VPC route tables**: Ensure routes to Transit Gateway exist in VPC route tables

### Internet Access Not Working

- **Verify NAT Gateway**: Ensure network account NAT Gateway is running
- **Check Transit Gateway routes**: Verify `0.0.0.0/0` route exists in environment route table
- **Check VPC routes**: Ensure workload VPC route tables route `0.0.0.0/0` to Transit Gateway

### Cross-Environment Communication Needed

If accounts in different environments need to communicate (not recommended), you would need to:
1. Create a shared route table or
2. Add static routes between route tables (defeats isolation purpose)

**Recommendation**: Use the network account as a proxy or API Gateway for cross-environment communication if absolutely necessary. This maintains security boundaries while allowing controlled access.

