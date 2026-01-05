output "cloudtrail_log_bucket_name" {
  description = "Name of the CloudTrail logs S3 bucket"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_log_bucket_arn" {
  description = "ARN of the CloudTrail logs S3 bucket"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_log_bucket_name" {
  description = "Name of the Config logs S3 bucket"
  value       = aws_s3_bucket.config_logs.id
}

output "config_log_bucket_arn" {
  description = "ARN of the Config logs S3 bucket"
  value       = aws_s3_bucket.config_logs.arn
}

output "vpc_flow_logs_log_group_name" {
  description = "Name of the VPC Flow Logs CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "vpc_flow_logs_log_group_arn" {
  description = "ARN of the VPC Flow Logs CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

