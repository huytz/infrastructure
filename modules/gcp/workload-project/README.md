# GCP Workload Project Module

Reusable Terraform module for creating GCP workload projects attached to a foundation project via Shared VPC.

## Core Components

- **GCP Project**: Creates project with unique ID
- **API Enablement**: Enables required Google Cloud APIs (GKE, Compute, IAM, etc.)
- **Shared VPC Attachment**: Attaches to foundation project as service project
- **Billing Association**: Associates project with billing account

## Key Principles

- Uses foundation project's Shared VPC network
- Service project (not host project)
- All necessary APIs enabled automatically

## Usage

### Basic Example

```hcl
module "workload_project" {
  source = "../../modules/gcp/workload-project"

  team_name              = "production"
  billing_account_id     = var.billing_account_id
  organization_id       = var.organization_id
  foundation_project_id  = var.foundation_project_id
}
```

### Terragrunt Example

```hcl
dependency "foundation" {
  config_path = "../foundation"
}

terraform {
  source = "../../modules/gcp/workload-project"
}

inputs = {
  team_name              = "production"
  billing_account_id     = local.root_config.locals.billing_account_id
  organization_id       = local.root_config.locals.organization_id
  foundation_project_id  = dependency.foundation.outputs.project_id
}
```

## Inputs

| Name | Description | Required |
|------|-------------|:--------:|
| `team_name` | Name of workload project | Yes |
| `billing_account_id` | Billing account ID | Yes |
| `foundation_project_id` | Foundation project ID | Yes |
| `organization_id` | Organization ID | No |
| `required_apis` | List of APIs to enable | No (has defaults) |
| `enable_shared_vpc` | Enable Shared VPC attachment | No (default: true) |
| `tags` | Additional labels | No |

## Outputs

- `project_id` - Project ID
- `project_name` - Project name
- `project_number` - Project number
- `service_project_attachment_id` - Shared VPC attachment ID
- `enabled_apis` - List of enabled APIs

## Dependencies

- Foundation project must be deployed first
- Foundation project must have Shared VPC enabled
- Billing account must exist

## Related Documentation

### Official GCP Landing Zone Documentation
- [GCP Landing Zone Guide](https://docs.cloud.google.com/architecture/landing-zones) - Official GCP landing zone architecture documentation

### GCP Service Documentation
- [GCP Shared VPC Documentation](https://cloud.google.com/vpc/docs/shared-vpc)
- [GCP Project Documentation](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
