# GCP SRE Team Project

This project uses the reusable `workload-project` module to create the SRE team project infrastructure connected to the foundation project via Shared VPC, following GCP best practices for multi-project architecture.

**Note**: This project is implemented using the `modules/gcp/workload-project` module. All infrastructure code is in the module, making it easy to create additional workload projects.

## Overview

The SRE Team Project provides:
- **GCP Project**: Creates a new project with unique ID (`sre-team-{random}`)
- **API Enablement**: Enables all required Google Cloud APIs (GKE, Compute, IAM, etc.)
- **Shared VPC Attachment**: Attaches to foundation project as a service project
- **Billing Association**: Associates project with billing account
- **Organization Management**: Associates project with GCP organization

**Key Principles**:
- **Shared VPC**: Uses the foundation project's Shared VPC network
- **Service Project**: This is a service project, not a host project
- **API Enablement**: All necessary APIs are automatically enabled
- **Consistent Structure**: Follows the same architecture as other workload projects

## Architecture

### Multi-Project Connectivity

```
Foundation Project (Host Project)
├── Shared VPC Network
├── Subnets (with secondary ranges for GKE)
└── Service Projects (attached via Shared VPC)
    └── SRE Team Project (this project)
```

### Shared VPC Model

- **Foundation Project**: Host project with Shared VPC network
- **SRE Team Project**: Service project attached to Shared VPC
- **Network Resources**: All network resources (VPC, subnets) in foundation project
- **Workload Resources**: Application resources (GKE, Compute Engine) in this project

## Prerequisites

- Foundation project must be deployed first
- AWS credentials configured with appropriate permissions
- Shared VPC enabled in foundation project

## Implementation

This project uses the reusable `modules/gcp/workload-project` module. The configuration is defined in:
- `terragrunt.hcl` - Terragrunt configuration with dependencies and inputs
- `main.tf` - Calls the workload-project module
- `variables.tf` - Variable definitions (passed to module)
- `outputs.tf` - Output passthrough from module

All infrastructure resources (project, APIs, Shared VPC attachment) are created by the module, ensuring consistency with other workload projects.

### Module Benefits

- **Reusability**: Same module used for all workload projects
- **Consistency**: All projects follow identical architecture
- **Maintainability**: Update module once, affects all projects
- **Fast Setup**: New projects can be created in minutes
- **Best Practices**: Module enforces GCP Shared VPC patterns

## Setup

### 1. Configure GCP Credentials

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
export GOOGLE_PROJECT="foundation-project-id"
export GOOGLE_REGION="us-central1"
```

### 2. Deploy Foundation Project First

```bash
cd gcp/foundation
terragrunt apply
```

### 3. Deploy SRE Team Project

```bash
cd gcp/sre-team
terragrunt plan    # Preview changes
terragrunt apply   # Apply changes
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `team_name` | Name of the workload project | `sre-team` | No |
| `billing_account_id` | The ID of the billing account | - | Yes (from root config) |
| `organization_id` | The ID of the organization | - | Yes (from root config) |
| `foundation_project_id` | The ID of the foundation project | - | Yes (from dependency) |
| `project_suffix_length` | Length of random suffix for project ID | `4` | No |
| `required_apis` | List of Google Cloud APIs to enable | See defaults | No |
| `enable_shared_vpc` | Enable Shared VPC attachment | `true` | No |
| `tags` | Additional tags/labels | `{Team = "SRE"}` | No |

### Dependencies

The SRE team project depends on the foundation project:
- Project ID (required - foundation project must be created first)

## Components

### 1. GCP Project
   - Project name: `sre-team`
   - Project ID: `sre-team-{random-suffix}`
   - Billing account associated
   - Organization associated

### 2. Enabled APIs
   - `container.googleapis.com` - Kubernetes Engine API
   - `compute.googleapis.com` - Compute Engine API
   - `iam.googleapis.com` - Identity and Access Management API
   - `cloudresourcemanager.googleapis.com` - Cloud Resource Manager API
   - `servicenetworking.googleapis.com` - Service Networking API
   - `dns.googleapis.com` - Cloud DNS API
   - `logging.googleapis.com` - Cloud Logging API
   - `monitoring.googleapis.com` - Cloud Monitoring API
   - `artifactregistry.googleapis.com` - Artifact Registry API

### 3. Shared VPC Attachment
   - Attaches SRE team project to foundation project's Shared VPC
   - Enables use of foundation project's network resources
   - **Note**: Shared VPC network is created and managed in foundation project

## Usage Example

### Deploy SRE Team Project

```bash
cd gcp/sre-team
terragrunt apply
```

### Use Outputs in Other Modules

```hcl
# In another Terragrunt module (e.g., gke/)
dependency "sre_team" {
  config_path = "../"
}

inputs = {
  project_id = dependency.sre_team.outputs.project_id
  project_name = dependency.sre_team.outputs.project_name
}
```

### Deploy GKE Cluster

After the project is created, you can deploy GKE clusters:

```bash
cd gcp/sre-team/gke
terragrunt apply
```

## Best Practices

1. **Separate Projects**: Foundation and workload projects are isolated for security
2. **Shared VPC**: Network resources centralized in foundation project
3. **Service Projects**: Workload projects are service projects, not host projects
4. **API Management**: All necessary APIs enabled automatically
5. **Consistent Naming**: Use descriptive project names
6. **Tagging**: Use tags for cost allocation and resource management

## Cost Considerations

- **Shared VPC**: No additional cost for Shared VPC attachment
- **API Enablement**: APIs are free, but usage may incur charges
- **Project Creation**: Free, but resources created incur charges

## Dependencies

- Foundation Project must be deployed first
- Google Provider >= 6.38.0, < 7.0.0
- Terraform >= 1.5.7
- Terragrunt (latest)

## Related Documentation

### Official GCP Landing Zone Documentation
- [GCP Landing Zone Guide](https://docs.cloud.google.com/architecture/landing-zones) - Official GCP landing zone architecture documentation

### GCP Service Documentation
- [GCP Shared VPC Documentation](https://cloud.google.com/vpc/docs/shared-vpc)
- [GCP Project Documentation](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

### Related Modules
- [Foundation Project README](../foundation/README.md)
- [Workload Project Module README](../../modules/gcp/workload-project/README.md)

