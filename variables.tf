variable "region" {
  description = "The AWS region to deploy the Lambda function and scanner instances."
  type        = string
  default     = "us-east-1"
}

variable "nightvision_token" {
  description = "NightVision API token"
  sensitive   = true
}

variable "create_scanner_infra" {
  description = "Optionally, create the Lambda infrastructure."
  type        = bool
}

variable "existing_scanner_lambda_name" {
  description = "The name of the Lambda function that will be used to scan the target."
  type        = string
  default     = "nightvision-scheduled-scan"
}

variable "existing_scheduler_role_name" {
  description = "The name of the IAM role that will be used to schedule the scans."
  type        = string
  default     = "NightVisionSchedulerExecutionRole"
}

variable "scan_configs" {
  description = "List of scan configs"
  type = list(object({
    # AWS Arguments
    schedule_name       = string
    schedule_expression = optional(string, "rate(7 days)")
    # AWS Resources
    security_group_id = string
    subnet_id         = string
    # NightVision Constructs
    project = string
    target  = string
    auth    = optional(string)
  }))
  default = []
}

variable "create_project_name" {
  description = "Optionally, create a NightVision target."
  type        = string
  default     = null
}

variable "web_targets" {
  description = "Web Application Targets to scan."
  type = list(object({
    url         = string
    project     = string
    target_name = string
  }))
  default = []
}

variable "openapi_url_targets" {
  description = "OpenAPI targets where the OpenAPI file is publicly accessible."
  type = list(object({
    url                = string
    project            = string
    target_name        = string
    openapi_public_url = string
  }))
  default = []
}

variable "openapi_file_targets" {
  description = "OpenAPI targets where the OpenAPI file is locally accessible."
  type = list(object({
    url               = string
    project           = string
    target_name       = string
    openapi_file_path = string
  }))
  default = []
}

variable "openapi_code_targets" {
  description = "OpenAPI targets where the OpenAPI file is generated from analyzing local code paths."
  type = list(object({
    url         = string
    project     = string
    language    = string
    target_name = string
    code_path   = string
  }))
  default = []
}
