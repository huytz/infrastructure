# AWS Subnet Generator Module

Reusable Terraform module for generating dynamic subnet configurations for AWS VPCs across multiple environments and availability zones.

## Core Components

- **Dynamic Subnet Generation**: Automatically generates public and private subnet configurations
- **Multi-Environment Support**: Supports multiple environments with isolated CIDR blocks
- **Multi-AZ Support**: Generates subnets across multiple availability zones
- **CIDR Calculation**: Automatic CIDR block calculation based on environment and subnet type

## Key Features

- Generates subnet configurations (no actual resources created)
- Supports multiple environments with unique CIDR bases
- Configurable subnet offsets for public/private subnets
- Automatic availability zone detection
- Outputs ready-to-use subnet configurations for `for_each`

## Usage

### Basic Example

```hcl
module "subnet_generator" {
  source = "../../modules/aws/subnet-generator"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
    }
    production = {
      description = "Production Environment"
      cidr_base   = "10.1"
    }
  }

  aws_region = "us-east-1"
}

# Use the generated configurations
resource "aws_subnet" "public" {
  for_each = module.subnet_generator.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.value.name
  }
}
```

### Advanced Example

```hcl
module "subnet_generator" {
  source = "../../modules/aws/subnet-generator"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
    }
  }

  aws_region           = "us-east-1"
  public_subnet_offset = 1   # Public subnets: 10.0.1.0/24, 10.0.2.0/24, etc.
  private_subnet_offset = 10 # Private subnets: 10.0.10.0/24, 10.0.11.0/24, etc.
  subnet_cidr_size      = 24
  max_azs              = 3
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environments` | Map of environments with CIDR base | `map(object)` | `{}` | Yes |
| `availability_zones` | Map of regions to AZ lists | `map(list(string))` | Predefined | No |
| `aws_region` | AWS region | `string` | `"us-east-1"` | No |
| `public_subnet_offset` | CIDR offset for public subnets | `number` | `1` | No |
| `private_subnet_offset` | CIDR offset for private subnets | `number` | `10` | No |
| `subnet_cidr_size` | CIDR size for subnets | `number` | `24` | No |
| `max_azs` | Maximum number of AZs to use | `number` | `3` | No |

## Outputs

| Name | Description |
|------|-------------|
| `subnet_configs` | Complete subnet configurations by environment |
| `public_subnets` | Flattened map of public subnets (ready for `for_each`) |
| `private_subnets` | Flattened map of private subnets (ready for `for_each`) |
| `subnet_to_env` | Map of subnet keys to environment names |
| `availability_zones` | List of availability zones for current region |
| `public_subnet_configs` | Public subnet configurations by environment |
| `private_subnet_configs` | Private subnet configurations by environment |

## CIDR Calculation

### Public Subnets
- **Formula**: `${cidr_base}.${public_subnet_offset + idx}.0/${subnet_cidr_size}`
- **Example**: For `cidr_base = "10.0"`, `public_subnet_offset = 1`:
  - AZ 1: `10.0.1.0/24`
  - AZ 2: `10.0.2.0/24`
  - AZ 3: `10.0.3.0/24`

### Private Subnets
- **Formula**: `${cidr_base}.${private_subnet_offset + idx}.0/${subnet_cidr_size}`
- **Example**: For `cidr_base = "10.0"`, `private_subnet_offset = 10`:
  - AZ 1: `10.0.10.0/24`
  - AZ 2: `10.0.11.0/24`
  - AZ 3: `10.0.12.0/24`

## Example Output Structure

```hcl
subnet_configs = {
  "sre-team" = {
    name        = "sre-team-subnet"
    cidr_base   = "10.0"
    description = "SRE Team Environment"
    environment = "sre-team"
    public_subnets = {
      "us-east-1a" = {
        name              = "sre-team-public-a"
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
      }
      # ... more AZs
    }
    private_subnets = {
      "us-east-1a" = {
        name              = "sre-team-private-a"
        cidr_block        = "10.0.10.0/24"
        availability_zone = "us-east-1a"
      }
      # ... more AZs
    }
  }
}
```

## Related Documentation

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS Subnet Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

