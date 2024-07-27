# ---------------------------------------------------------------------------------------------------------------------
# Naming
# ---------------------------------------------------------------------------------------------------------------------
variable "schedule_name" {
  description = "The name of the schedule"
  type        = string
}

variable "schedule_expression" {
  default     = "rate(24 hours)"
  description = "Defines when the schedule runs. Read more in Schedule types on EventBridge Scheduler: https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html"
  type        = string
}

variable "scheduler_role_arn" {
  description = "The ARN of the IAM role that EventBridge Scheduler uses to invoke the Lambda function."
  type        = string
}

variable "scanner_lambda_arn" {
  description = "The ARN of the Lambda function that will be invoked by the schedule."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Scanner arguments
# ---------------------------------------------------------------------------------------------------------------------
variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "target" {
  description = "The target application"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "auth" {
  description = "Optional auth key"
  type        = string
  default     = null
}
