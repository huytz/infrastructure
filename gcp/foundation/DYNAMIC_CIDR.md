# Dynamic CIDR Planning System

## Overview
This system automatically generates subnet configurations for multiple environments using a dynamic, scalable approach that follows GCP best practices. All resources are deployed in a single region (us-central1) for simplicity.

## Architecture

### 1. Environment Definitions
```hcl
environments = {
  sre-team = {
    description = "SRE Team Environment"
    cidr_base  = "10.0"
  }
  xxxx = {
    description = "xxx Environment"
    cidr_base  = "10.1"
  }
  yyy = {
    description = "yyy Environment"
    cidr_base  = "10.2"
  }
  zzz = {
    description = "zzz Environment"
    cidr_base  = "10.3"
  }
}
```

### 2. Secondary Range Types
```hcl
secondary_ranges = {
  pods = {
    range_name_suffix = "pods-range"
    cidr_offset      = 1
    cidr_size        = 20
  }
  services = {
    range_name_suffix = "services-range"
    cidr_offset      = 2
    cidr_size        = 20
  }
}
```

## Generated CIDR Ranges

### Primary Subnets
| Environment | Subnet Name | CIDR Range | Description |
|-------------|-------------|------------|-------------|
| sre-team | sre-team-subnet | 10.0.1.0/24 | SRE Team Environment |


### Secondary IP Ranges (CIDR /20)

#### Pods Ranges
- **sre-team-pods-range**: 10.0.11.0/20 (4,096 IPs)

#### Services Ranges
- **sre-team-services-range**: 10.0.12.0/20 (4,096 IPs)

## Benefits of Dynamic Configuration

### 1. Scalability
- Easy to add new environments by adding to the `environments` map
- Easy to add new secondary range types by adding to the `secondary_ranges` map
- Single region deployment simplifies management

### 2. Consistency
- All subnets follow the same naming convention
- All CIDR ranges follow a predictable pattern
- All environments get the same structure

### 3. Maintainability
- Single source of truth for all configurations
- Changes propagate automatically to all environments
- No manual CIDR calculations required

### 4. Best Practices
- Follows GCP's recommended subnet sizing
- Proper separation between environments
- Efficient IP address utilization with /20 ranges
- Single region deployment reduces complexity

## CIDR Size Benefits

### Using /20 Instead of /16
- **IP Addresses**: 4,096 (2^12) instead of 65,536 (2^16)
- **Efficiency**: Better IP address utilization
- **Cost**: Reduces wasted IP addresses
- **Management**: Easier to understand and manage
- **GKE Friendly**: Still provides plenty of IPs for pods and services

## Usage Examples

### Adding a New Environment
```hcl
# Add to environments map
testing = {
  description = "Testing Environment"
  cidr_base  = "10.4"
}
```

### Adding a New Secondary Range Type
```hcl
# Add to secondary_ranges map
databases = {
  range_name_suffix = "db-range"
  cidr_offset      = 3
  cidr_size        = 20
}
```

### Modifying CIDR Size
```hcl
# Change cidr_size in secondary_ranges
secondary_ranges = {
  pods = {
    range_name_suffix = "pods-range"
    cidr_offset      = 1
    cidr_size        = 20  # /20 = 4,096 IPs
  }
}
```

## Output Information

The system provides comprehensive outputs:

```hcl
output "subnet_configurations" {
  description = "Generated subnet configurations"
  value = {
    for key, subnet in google_compute_subnetwork.dynamic_subnets : key => {
      name             = subnet.name
      ip_cidr_range    = subnet.ip_cidr_range
      region           = subnet.region
      secondary_ranges = subnet.secondary_ip_range
    }
  }
}
```

This output provides a complete view of all generated subnets and their configurations for easy reference and integration with other systems.

## Deployment Summary

### Total Resources Created
- **1 Subnets** (one per environment)
- **2 Secondary Ranges** (2 per subnet)
- **All in us-central1 region**

### IP Address Allocation
- **Primary Subnets**: 256 IPs each (/24)
- **Secondary Ranges**: 4,096 IPs each (/20)
- **Total IPs per Environment**: 8,448 IPs
- **Total IPs across all environments**: 33,792 IPs

### Environment Separation
- **SRE Team**: 10.0.x.x range
