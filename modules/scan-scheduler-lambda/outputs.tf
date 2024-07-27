output "scanner_lambda_arn" {
  value       = aws_lambda_function.python_lambda.arn
  description = "The ARN of the Lambda function that will be invoked by the schedule."
}

output "scheduler_role_arn" {
  value       = aws_iam_role.scheduler.arn
  description = "The ARN of the IAM role that EventBridge Scheduler uses to invoke the Lambda function."
}