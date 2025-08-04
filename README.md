# Infrastructure as Code with Terragrunt

This repository contains the infrastructure configuration for the huytz project using Terraform and Terragrunt.

## Prerequisites

Before using this repository, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.5.7)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup

### 1. Set Environment Variables

Set your GCP billing account ID as an environment variable:

```bash
export BILLING_ACCOUNT_ID="your-billing-account-id"
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
│   └── huytz/
│       ├── terragrunt.hcl      # GCP project configuration
│       ├── project.tf          # GCP project resource
│       ├── apis.tf             # Google APIs to enable
│       ├── variables.tf        # Input variables
│       ├── outputs.tf          # Output values
│       ├── network/
│       │   ├── terragrunt.hcl  # Network configuration
│       │   ├── main.tf         # VPC network and subnet resources
│       │   ├── variables.tf    # Network variables
│       │   └── outputs.tf      # Network outputs
│       └── kubernetes/
│           ├── terragrunt.hcl  # Kubernetes configuration
│           ├── gke.tf          # GKE cluster configuration
│           └── variables.tf    # Kubernetes variables
```

## Usage

### Deploy Everything

To deploy the entire infrastructure:

```bash
terragrunt run-all plan    # Preview changes
terragrunt run-all apply   # Apply changes
```

### Deploy Individual Components

#### Deploy GCP Project and APIs

```bash
cd gcp/huytz
terragrunt plan
terragrunt apply
```

#### Deploy Network Infrastructure

```bash
cd gcp/huytz/network
terragrunt plan
terragrunt apply
```

#### Deploy GKE Cluster

```bash
cd gcp/huytz/kubernetes
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
cd gcp/huytz/kubernetes
terragrunt destroy

cd ../network
terragrunt destroy

cd ..
terragrunt destroy
```

## Configuration

### Billing Account

The billing account ID is configured via the `BILLING_ACCOUNT_ID` environment variable. This is used to associate the GCP project with your billing account.

### GCP Project

The project is automatically created with a unique ID based on the `huytz` prefix and a random suffix.

### Network Infrastructure

The network module creates:
- **VPC Network**: `gke-network` with auto-created subnets disabled
- **Subnet**: `gke-subnet` with proper IP ranges:
  - Primary range: `10.0.0.0/24` for nodes
  - Secondary range for pods: `10.1.0.0/16`
  - Secondary range for services: `10.2.0.0/16`

### GKE Cluster

The GKE cluster is configured with:
- Private cluster with private nodes
- Default node pool with e2-medium instances
- Auto-scaling enabled (1-100 nodes)
- Service account for node pool
- Uses the custom VPC network and subnet

## Dependencies

The infrastructure follows this dependency order:
1. **GCP Project** - Creates the project and enables APIs
2. **Network** - Creates VPC network and subnet (depends on project)
3. **GKE Cluster** - Creates the Kubernetes cluster (depends on project and network)

## APIs Enabled

The following Google APIs are automatically enabled:

- `container.googleapis.com` - Kubernetes Engine API
- `compute.googleapis.com` - Compute Engine API
- `iam.googleapis.com` - Identity and Access Management API
- `cloudresourcemanager.googleapis.com` - Cloud Resource Manager API
- `servicenetworking.googleapis.com` - Service Networking API
- `dns.googleapis.com` - Cloud DNS API
- `logging.googleapis.com` - Cloud Logging API
- `monitoring.googleapis.com` - Cloud Monitoring API
- `artifactregistry.googleapis.com` - Artifact Registry API

## Troubleshooting

### Common Issues

1. **Billing Account Not Set**
   ```
   Error: billing_account_id is required
   ```
   Solution: Set the `BILLING_ACCOUNT_ID` environment variable.

2. **Kubernetes Engine API Not Enabled**
   ```
   Error: Kubernetes Engine API has not been used in project...
   ```
   Solution: Ensure the GCP project and APIs are deployed before the GKE cluster.

3. **Network Dependencies**
   ```
   Error: Pod secondary range not found...
   ```
   Solution: Ensure the network module is deployed before the GKE cluster.

4. **Authentication Issues**
   ```
   Error: google: could not find default credentials
   ```
   Solution: Run `gcloud auth application-default login`.

### Getting Help

- Check the [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/)
- Review the [Terraform Google provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- Check the [GKE module documentation](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine)

## Contributing

1. Make changes to the Terraform configuration files
2. Test your changes with `terragrunt plan`
3. Apply changes with `terragrunt apply`
4. Commit and push your changes

## License

This project is licensed under the MIT License.
