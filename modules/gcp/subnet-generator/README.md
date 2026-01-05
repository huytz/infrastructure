# GCP Subnet Generator Module

Reusable Terraform module for generating dynamic subnet configurations for GCP VPCs with secondary IP ranges for GKE.

## Core Components

- **Dynamic Subnet Generation**: Automatically generates subnet configurations with secondary IP ranges
- **Multi-Environment Support**: Supports multiple environments with isolated CIDR blocks
- **Secondary IP Ranges**: Automatic generation of secondary ranges for pods and services
- **CIDR Calculation**: Automatic CIDR block calculation with proper /20 boundaries

## Key Features

- Generates subnet configurations (no actual resources created)
- Supports multiple environments with unique CIDR bases
- Automatic secondary IP range generation for GKE
- Configurable CIDR offsets and sizes
- Outputs ready-to-use subnet configurations for `for_each`

## Usage

### Basic Example

```hcl
module "subnet_generator" {
  source = "../../modules/gcp/subnet-generator"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
      region      = "us-central1"
    }
    production = {
      description = "Production Environment"
      cidr_base   = "10.1"
      region      = "us-central1"
    }
  }
}

# Use the generated configurations
resource "google_compute_subnetwork" "dynamic_subnets" {
  for_each = module.subnet_generator.subnets

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.network.id

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
```

### Advanced Example

```hcl
module "subnet_generator" {
  source = "../../modules/gcp/subnet-generator"

  environments = {
    sre-team = {
      description = "SRE Team Environment"
      cidr_base   = "10.0"
      region      = "us-central1"
    }
  }

  secondary_ranges = {
    pods = {
      range_name_suffix = "pods-range"
      cidr_offset       = 1
      cidr_size         = 20
    }
    services = {
      range_name_suffix = "services-range"
      cidr_offset       = 2
      cidr_size         = 20
    }
  }

  primary_subnet_cidr_size = 24
  primary_subnet_offset    = 1
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environments` | Map of environments with CIDR base and region | `map(object)` | `{}` | Yes |
| `secondary_ranges` | Map of secondary IP range configurations | `map(object)` | Predefined | No |
| `primary_subnet_cidr_size` | CIDR size for primary subnets | `number` | `24` | No |
| `primary_subnet_offset` | CIDR offset for primary subnets | `number` | `1` | No |

## Outputs

| Name | Description |
|------|-------------|
| `subnet_configs` | Complete subnet configurations by environment |
| `subnets` | Flattened map of subnets (ready for `for_each`) |
| `flattened_subnets` | List of flattened subnet configurations |
| `subnet_configs_by_region` | Subnet configurations grouped by region |
| `secondary_ranges_by_environment` | Secondary IP ranges grouped by environment |

## CIDR Calculation

### Primary Subnets
- **Formula**: `${cidr_base}.${primary_subnet_offset}.0/${primary_subnet_cidr_size}`
- **Example**: For `cidr_base = "10.0"`, `primary_subnet_offset = 1`:
  - Primary subnet: `10.0.1.0/24` (256 IPs for nodes)

### Secondary IP Ranges
- **Formula**: `${cidr_base}.${cidr_offset * 16}.0/${cidr_size}`
- **Example**: For `cidr_base = "10.0"`:
  - Pods: `10.0.16.0/20` (4,096 IPs) - offset 1 * 16 = 16
  - Services: `10.0.32.0/20` (4,096 IPs) - offset 2 * 16 = 32

**Note**: Secondary ranges use /20 boundaries (multiples of 16) to ensure proper CIDR allocation.

## Example Output Structure

```hcl
subnet_configs = {
  "sre-team" = {
    name          = "sre-team-subnet"
    ip_cidr_range = "10.0.1.0/24"
    region        = "us-central1"
    environment   = "sre-team"
    description   = "SRE Team Environment"
    secondary_ranges = {
      "pods" = {
        range_name    = "sre-team-pods-range"
        ip_cidr_range = "10.0.16.0/20"
      }
      "services" = {
        range_name    = "sre-team-services-range"
        ip_cidr_range = "10.0.32.0/20"
      }
    }
  }
}
```

## Related Documentation

- [GCP VPC Documentation](https://cloud.google.com/vpc/docs)
- [GCP Subnet Documentation](https://cloud.google.com/vpc/docs/subnets)
- [GKE Secondary IP Ranges](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips)

