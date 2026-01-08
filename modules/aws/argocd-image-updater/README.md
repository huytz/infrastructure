# ArgoCD Image Updater CloudEvents Module

This Terraform module configures AWS EventBridge to automatically send ECR image push events to ArgoCD Image Updater via CloudEvents format.

## Features

- Captures ECR image push events using EventBridge rules
- Transforms AWS ECR events to CloudEvents format
- Sends events to ArgoCD Image Updater webhook endpoint
- Supports API key authentication
- Configurable retry policies and rate limiting
- Optional filtering by ECR repository names

## Usage

```hcl
module "argocd_image_updater" {
  source = "../../modules/aws/argocd-image-updater"

  account_id     = "123456789012"
  webhook_url    = "https://argocd.example.com/api/webhook"
  webhook_secret = "your-api-key-secret"

  aws_region = "us-east-1"

  # Optional: Filter by specific repositories
  ecr_repository_filter = ["my-app", "another-app"]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | AWS Account ID where ECR repositories are located | `string` | n/a | yes |
| webhook_url | ArgoCD Image Updater webhook URL endpoint | `string` | n/a | yes |
| webhook_secret | API key/secret for authenticating with the ArgoCD Image Updater webhook | `string` | n/a | yes |
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| ecr_repository_filter | Optional list of ECR repository names to filter events. If empty, all repositories will trigger events. | `list(string)` | `[]` | no |
| rule_name | Custom name for the EventBridge rule | `string` | `""` | no |
| connection_name | Custom name for the EventBridge connection | `string` | `""` | no |
| api_destination_name | Custom name for the API destination | `string` | `""` | no |
| iam_role_name | Custom name for the IAM role | `string` | `""` | no |
| target_id | Custom ID for the EventBridge target | `string` | `""` | no |
| api_key_header_name | HTTP header name for the API key authentication | `string` | `"X-Webhook-Secret"` | no |
| invocation_rate_limit_per_second | Maximum number of invocations per second for the API destination | `number` | `10` | no |
| maximum_event_age_in_seconds | Maximum age in seconds for events before they are discarded | `number` | `3600` | no |
| maximum_retry_attempts | Maximum number of retry attempts for failed invocations | `number` | `3` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| eventbridge_rule_arn | ARN of the EventBridge rule for ECR push events |
| eventbridge_rule_name | Name of the EventBridge rule |
| eventbridge_connection_arn | ARN of the EventBridge connection |
| eventbridge_connection_name | Name of the EventBridge connection |
| api_destination_arn | ARN of the API destination |
| api_destination_name | Name of the API destination |
| iam_role_arn | ARN of the IAM role for EventBridge |
| iam_role_name | Name of the IAM role for EventBridge |
| eventbridge_target_id | ID of the EventBridge target |

## How It Works

1. **EventBridge Rule**: Captures ECR image push events when images are successfully pushed with tags
2. **Input Transformer**: Converts AWS ECR event format to CloudEvents format
3. **API Destination**: Sends the transformed event to the ArgoCD Image Updater webhook
4. **Authentication**: Uses API key authentication via EventBridge Connection
5. **Retry Policy**: Automatically retries failed invocations up to 3 times

## CloudEvents Format

The module transforms ECR events to CloudEvents format:

```json
{
  "specversion": "1.0",
  "id": "<event-id>",
  "type": "com.amazon.ecr.image.push",
  "source": "urn:aws:ecr:<region>:<account>:repository/<repo>",
  "subject": "<repo>:<tag>",
  "time": "<timestamp>",
  "datacontenttype": "application/json",
  "data": {
    "repositoryName": "<repo>",
    "imageDigest": "<digest>",
    "imageTag": "<tag>",
    "registryId": "<account>"
  }
}
```

## Repository Filtering

To filter events for specific ECR repositories, use the `ecr_repository_filter` variable:

```hcl
ecr_repository_filter = ["production-app", "staging-app"]
```

If left empty, all ECR repositories in the account will trigger events.

## References

- [ArgoCD Image Updater CloudEvents Example](https://github.com/argoproj-labs/argocd-image-updater/blob/master/config/examples/cloudevents/terraform/main.tf)
- [AWS EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/)
- [CloudEvents Specification](https://cloudevents.io/)
