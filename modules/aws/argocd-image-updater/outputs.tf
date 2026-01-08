output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for ECR push events"
  value       = aws_cloudwatch_event_rule.ecr_push.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.ecr_push.name
}

output "eventbridge_connection_arn" {
  description = "ARN of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.webhook.arn
}

output "eventbridge_connection_name" {
  description = "Name of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.webhook.name
}

output "api_destination_arn" {
  description = "ARN of the API destination"
  value       = aws_cloudwatch_event_api_destination.webhook.arn
}

output "api_destination_name" {
  description = "Name of the API destination"
  value       = aws_cloudwatch_event_api_destination.webhook.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for EventBridge"
  value       = aws_iam_role.eventbridge.arn
}

output "iam_role_name" {
  description = "Name of the IAM role for EventBridge"
  value       = aws_iam_role.eventbridge.name
}

output "eventbridge_target_id" {
  description = "ID of the EventBridge target"
  value       = aws_cloudwatch_event_target.api_destination.target_id
}
