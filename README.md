# Infrastructure as Code with Terragrunt

This repository contains the infrastructure configuration for the huytz project using Terraform and Terragrunt, implementing a multi-environment GCP infrastructure with dynamic CIDR allocation.

## Prerequisites

Before using this repository, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.5.7)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup

### 1. Set Environment Variables

Set your GCP billing account ID and organization ID as environment variables:

```bash
export BILLING_ACCOUNT_ID="your-billing-account-id"
export ORGANIZATION_ID="your-organization-id"
```

You can find your billing account ID in the [Google Cloud Console](https://console.cloud.google.com/billing) or by running:

```bash
gcloud billing accounts list
```

### 2. Authenticate with Google Cloud

```bash
gcloud auth application-default login
```

### 3. Set your GCP Project (Optional)

If you want to work with a specific GCP project:

```bash
gcloud config set project YOUR_PROJECT_ID
```

## Project Structure

```
infrastructure/
├── root.hcl                    # Root Terragrunt configuration
├── gcp/
│   ├── foundation/             # Foundation infrastructure
│   │   ├── terragrunt.hcl      # Foundation configuration
│   │   ├── project.tf          # GCP project resource
│   │   ├── networks.tf         # VPC network and dynamic subnets
│   │   ├── cloud-nat.tf        # Cloud NAT configuration
│   │   ├── variables.tf        # Input variables
│   │   ├── outputs.tf          # Output values
│   │   └── DYNAMIC_CIDR.md     # CIDR allocation documentation
│   └── sre-team/               # SRE Team environment
│       ├── terragrunt.hcl      # SRE Team project configuration
│       ├── project.tf          # SRE Team GCP project
│       ├── variables.tf        # SRE Team variables
│       ├── outputs.tf          # SRE Team outputs
│       └── gke/                # GKE cluster
│           ├── terragrunt.hcl  # GKE configuration
│           ├── main.tf         # GKE cluster resources
│           └── variables.tf    # GKE variables
```

## Architecture Overview

### Foundation Module
The foundation module creates the core infrastructure:
- **GCP Project**: Creates the foundation project with billing account association
- **VPC Network**: Creates a shared VPC network with auto-created subnets disabled
- **Dynamic Subnets**: Automatically generates subnets for all environments using a scalable CIDR allocation system
- **Cloud NAT**: Provides internet access for private instances
- **Google APIs**: Enables all necessary APIs for the infrastructure

### SRE Team Module
The SRE team module creates environment-specific resources:
- **GCP Project**: Creates a separate project for the SRE team
- **GKE Cluster**: Deploys a private GKE cluster using the foundation network infrastructure

### Dynamic CIDR Allocation
The system uses a dynamic CIDR allocation strategy that:
- Automatically generates subnet configurations for multiple environments
- Follows GCP best practices with proper IP range sizing
- Uses /24 primary subnets (256 IPs) for nodes
- Uses /20 secondary ranges for pods and services (4,096 IPs each)
- Provides predictable IP allocation with automatic calculation
- Enables easy scaling by adding environments to the configuration map

## Usage

### Deploy Everything

To deploy the entire infrastructure:

```bash
terragrunt run-all plan    # Preview changes
terragrunt run-all apply   # Apply changes
```

### Deploy Individual Components

#### Deploy Foundation Infrastructure

```bash
cd gcp/foundation
terragrunt plan
terragrunt apply
```

#### Deploy SRE Team Environment

```bash
cd gcp/sre-team
terragrunt plan
terragrunt apply
```

#### Deploy GKE Cluster

```bash
cd gcp/sre-team/gke
terragrunt plan
terragrunt apply
```

### Destroy Infrastructure

To destroy all resources:

```bash
terragrunt run-all destroy
```

Or destroy individual components:

```bash
cd gcp/sre-team/gke
terragrunt destroy

cd ../..
terragrunt destroy

cd ../foundation
terragrunt destroy
```

## Configuration

### Environment Variables

- `BILLING_ACCOUNT_ID`: Required for associating projects with billing
- `ORGANIZATION_ID`: Required for project creation and organization policies

### Foundation Project

The foundation project is automatically created with a unique ID and includes:
- Billing account association
- All necessary Google APIs enabled
- Shared VPC network infrastructure
- Cloud NAT for private instance internet access

### Network Infrastructure

The foundation network module creates:
- **VPC Network**: Shared network with auto-created subnets disabled
- **Dynamic Subnets**: Automatically generated for all environments:
  - **sre-team-subnet**: `10.0.1.0/24` for nodes (256 IPs)
  - **sre-team-pods-range**: `10.0.16.0/20` for pods (4,096 IPs)
  - **sre-team-services-range**: `10.0.32.0/20` for services (4,096 IPs)
- **Flow Logs**: Enabled for network monitoring with 5-second aggregation intervals
- **Cloud NAT**: Provides internet access for private instances

### GKE Cluster

The GKE cluster is configured with:
- **Cluster Name**: `gke-test`
- **Region**: `us-central1` with single zone deployment (`us-central1-a`)
- **Private Cluster**: Private nodes with public control plane access
- **Node Pool**: 
  - Machine type: `e2-medium`
  - Auto-scaling: 1-4 nodes
  - Disk: 100GB SSD
  - OS: Container-Optimized OS with containerd
- **Network Features**:
  - Uses foundation VPC network and subnet
  - Proper secondary IP ranges for pods and services
  - Master authorized networks: `0.0.0.0/0` (all IPs)
- **Disabled Features**: HTTP load balancing, network policy, Istio, Cloud Run, DNS cache
- **Enabled Features**: Horizontal pod autoscaling, auto-repair, auto-upgrade

## Dependencies

The infrastructure follows this dependency order:
1. **Foundation** - Creates shared VPC network and enables APIs
2. **SRE Team Project** - Creates environment-specific project
3. **GKE Cluster** - Creates the Kubernetes cluster (depends on foundation network)

## APIs Enabled

The following Google APIs are automatically enabled in the foundation project:

- `container.googleapis.com` - Kubernetes Engine API
- `compute.googleapis.com` - Compute Engine API
- `iam.googleapis.com` - Identity and Access Management API
- `cloudresourcemanager.googleapis.com` - Cloud Resource Manager API
- `servicenetworking.googleapis.com` - Service Networking API
- `dns.googleapis.com` - Cloud DNS API
- `logging.googleapis.com` - Cloud Logging API
- `monitoring.googleapis.com` - Cloud Monitoring API

These APIs are required for:
- GKE cluster creation and management
- VPC network and subnet operations
- Cloud NAT and routing
- IAM service account management
- Monitoring and logging integration

## Adding New Environments

To add a new environment:

1. **Update Foundation Module**: Add the new environment to the `environments` map in `gcp/foundation/networks.tf`
2. **Create Environment Module**: Create a new directory under `gcp/` for the environment
3. **Configure Dependencies**: Set up terragrunt dependencies to use the foundation network

Example environment addition:
```hcl
# In gcp/foundation/networks.tf
environments = {
  sre-team = {
    description = "SRE Team Environment"
    cidr_base   = "10.0"
  }
  new-env = {
    description = "New Environment"
    cidr_base   = "10.1"
  }
}
```

This will automatically generate:
- **Primary subnet**: `new-env-subnet` with CIDR `10.1.1.0/24`
- **Pods range**: `new-env-pods-range` with CIDR `10.1.16.0/20`
- **Services range**: `new-env-services-range` with CIDR `10.1.32.0/20`

### CIDR Allocation Strategy

The system uses a predictable CIDR allocation pattern:
- **Primary subnets**: `/24` (256 IPs) for nodes
- **Secondary ranges**: `/20` (4,096 IPs) for pods and services
- **Environment separation**: Each environment gets its own `10.x.x.x` range
- **Automatic calculation**: Secondary ranges are calculated using offsets (16, 32, etc.)

For detailed CIDR planning information, see `gcp/foundation/DYNAMIC_CIDR.md`.

## Troubleshooting

### Common Issues

1. **Environment Variables Not Set**
   ```
   Error: Required environment variable BILLING_ACCOUNT_ID - not found
   ```
   Solution: Set the required environment variables.

2. **Foundation Dependencies**
   ```
   Error: This object does not have an attribute named "subnet_configurations"
   ```
   Solution: Ensure the foundation module is deployed before dependent modules.

3. **GCP Permissions**
   ```
   Error: Permission denied on resource project
   ```
   Solution: Ensure proper GCP authentication and permissions.

4. **Network Dependencies**
   ```
   Error: Pod secondary range not found
   ```
   Solution: Ensure the foundation network module is deployed before GKE.

### Getting Help

- Check the [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/)
- Review the [Terraform Google provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- Check the [GKE module documentation](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine)
- Review the `gcp/foundation/DYNAMIC_CIDR.md` file for detailed CIDR allocation information
- Check the [GCP VPC documentation](https://cloud.google.com/vpc/docs) for network best practices

## Contributing

1. Make changes to the Terraform configuration files
2. Test your changes with `terragrunt plan`
3. Apply changes with `terragrunt apply`
4. Update documentation as needed
5. Commit and push your changes

## License

This project is licensed under the MIT License.
