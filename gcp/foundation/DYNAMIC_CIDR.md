# Dynamic CIDR Planning System

## Overview
This system automatically generates subnet configurations for multiple environments using a dynamic, scalable approach that follows GCP best practices. All resources are deployed in a single region (us-central1) for simplicity and cost optimization.

## Architecture

### 1. Environment Definitions
```hcl
environments = {
  sre-team = {
    description = "SRE Team Environment"
    cidr_base   = "10.0"
  }
  # Add new environments here following the same pattern
  # new-env = {
  #   description = "New Environment"
  #   cidr_base   = "10.1"
  # }
}
```

### 2. Secondary Range Types
```hcl
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
```

## CIDR Calculation Logic

### Primary Subnet Calculation
- **Formula**: `${cidr_base}.1.0/24`
- **Example**: For `cidr_base = "10.0"` → `10.0.1.0/24`
- **Size**: 256 IP addresses (2^8)

### Secondary Range Calculation
- **Formula**: `${cidr_base}.${offset * 16}.0/${size}`
- **Pods**: `10.0.16.0/20` (offset 1 * 16 = 16)
- **Services**: `10.0.32.0/20` (offset 2 * 16 = 32)
- **Size**: 4,096 IP addresses each (2^12)

### Why Use Offset * 16?
This ensures proper /20 boundaries:
- 16 = 2^4, which aligns with /20 subnet boundaries
- Prevents overlapping ranges
- Maintains clean network segmentation

## Generated CIDR Ranges

### Primary Subnets
| Environment | Subnet Name | CIDR Range | IP Count | Description |
|-------------|-------------|------------|----------|-------------|
| sre-team | sre-team-subnet | 10.0.1.0/24 | 256 | SRE Team Environment |

### Secondary IP Ranges (CIDR /20)

#### Pods Ranges
- **sre-team-pods-range**: 10.0.16.0/20 (4,096 IPs)
  - Range: 10.0.16.0 - 10.0.31.255
  - Usable: 10.0.16.1 - 10.0.31.254

#### Services Ranges
- **sre-team-services-range**: 10.0.32.0/20 (4,096 IPs)
  - Range: 10.0.32.0 - 10.0.47.255
  - Usable: 10.0.32.1 - 10.0.47.254

## Benefits of Dynamic Configuration

### 1. Scalability
- Easy to add new environments by adding to the `environments` map
- Easy to add new secondary range types by adding to the `secondary_ranges` map
- Single region deployment simplifies management and reduces costs
- Automatic CIDR calculation eliminates manual planning errors

### 2. Consistency
- All subnets follow the same naming convention: `${env}-subnet`
- All secondary ranges follow: `${env}-${type}-range`
- All CIDR ranges follow a predictable mathematical pattern
- All environments get identical structure and capabilities

### 3. Maintainability
- Single source of truth for all configurations in `networks.tf`
- Changes propagate automatically to all environments
- No manual CIDR calculations required
- Clear separation of concerns with modular design

### 4. Best Practices
- Follows GCP's recommended subnet sizing for GKE
- Proper separation between environments prevents conflicts
- Efficient IP address utilization with /20 ranges
- Single region deployment reduces complexity and latency
- Flow logs enabled for network monitoring

## CIDR Size Benefits

### Using /20 Instead of /16
- **IP Addresses**: 4,096 (2^12) instead of 65,536 (2^16)
- **Efficiency**: Better IP address utilization, reduces waste
- **Cost**: Reduces wasted IP addresses and associated costs
- **Management**: Easier to understand and manage smaller ranges
- **GKE Friendly**: Still provides plenty of IPs for pods and services
- **Performance**: Smaller routing tables improve network performance

### Using /24 for Primary Subnets
- **IP Addresses**: 256 (2^8) for nodes
- **Efficiency**: Appropriate size for typical node counts
- **Scalability**: Can accommodate up to 254 nodes per environment
- **Cost**: Minimizes wasted IP addresses

## Usage Examples

### Adding a New Environment
```hcl
# Add to environments map in gcp/foundation/networks.tf
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
```

This automatically generates:
- **Primary subnet**: `production-subnet` with CIDR `10.1.1.0/24`
- **Pods range**: `production-pods-range` with CIDR `10.1.16.0/20`
- **Services range**: `production-services-range` with CIDR `10.1.32.0/20`

### Adding a New Secondary Range Type
```hcl
# Add to secondary_ranges map
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
  databases = {
    range_name_suffix = "db-range"
    cidr_offset       = 3
    cidr_size         = 20
  }
}
```

This would create:
- **Database range**: `sre-team-db-range` with CIDR `10.0.48.0/20`

### Modifying CIDR Size
```hcl
# Change cidr_size in secondary_ranges for larger ranges
secondary_ranges = {
  pods = {
    range_name_suffix = "pods-range"
    cidr_offset       = 1
    cidr_size         = 19  # /19 = 8,192 IPs
  }
}
```

## Output Information

The system provides comprehensive outputs for integration with other modules:

```hcl
output "subnet_configurations" {
  description = "Subnet configurations with flattened map-based secondary ranges"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => {
      name          = subnet.name
      ip_cidr_range = subnet.ip_cidr_range
      region        = subnet.region
      self_link     = subnet.self_link
      secondary_ranges = {
        for range in subnet.secondary_ip_range : range.range_name => {
          range_name    = range.range_name
          ip_cidr_range = range.ip_cidr_range
        }
      }
    }
  }
}
```

This output provides:
- Complete subnet information for each environment
- Flattened secondary ranges as maps for easy access
- Self-links for direct GCP resource references
- Structured data for consumption by dependent modules

## Deployment Summary

### Current Resources
- **1 Environment**: sre-team
- **1 Primary Subnet**: sre-team-subnet
- **2 Secondary Ranges**: pods and services
- **Region**: us-central1

### IP Address Allocation
- **Primary Subnets**: 256 IPs each (/24)
- **Secondary Ranges**: 4,096 IPs each (/20)
- **Total IPs per Environment**: 8,448 IPs
- **Current Total IPs**: 8,448 IPs

### Scalability Projections
With the current design, you can add up to 254 additional environments (10.1.x.x to 10.254.x.x):
- **Maximum Environments**: 254
- **Maximum Total IPs**: 2,145,792 IPs
- **Maximum Subnets**: 254
- **Maximum Secondary Ranges**: 508

### Environment Separation
- **Current**: SRE Team uses 10.0.x.x range
- **Future**: Each new environment gets its own 10.x.x.x range
- **Isolation**: Complete network isolation between environments
- **Routing**: Automatic routing within each environment

## Integration with GKE

The subnet configurations are designed specifically for GKE clusters:

### GKE Requirements
- **Primary subnet**: For node IPs (typically /24 is sufficient)
- **Pods range**: For pod IPs (requires /20 or larger for scale)
- **Services range**: For service IPs (requires /20 or larger for scale)

### Automatic Integration
The `subnet_configurations` output is consumed by the GKE module:
```hcl
locals {
  subnet_configurations = jsondecode(var.subnet_configurations)
  sre_team_subnet       = local.subnet_configurations["sre-team"]
  subnet_name           = local.sre_team_subnet.name
  pods_range            = local.sre_team_subnet.secondary_ranges["sre-team-pods-range"].ip_cidr_range
  services_range        = local.sre_team_subnet.secondary_ranges["sre-team-services-range"].ip_cidr_range
}
```

This ensures seamless integration between the network infrastructure and GKE clusters.
