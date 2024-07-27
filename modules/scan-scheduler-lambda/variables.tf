# ---------------------------------------------------------------------------------------------------------------------
# Resource naming
# ---------------------------------------------------------------------------------------------------------------------
variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "nightvision-scheduled-scan"
}

variable "lambda_role_name" {
  description = "The name of the IAM role."
  type        = string
  default     = "nightvision-scheduled-scan"
}

variable "launch_template_name" {
  description = "The name of the launch template."
  type        = string
  default     = "nightvision-scanner"
}

variable "scanner_instance_profile_name" {
  description = "The name of the instance profile."
  type        = string
  default     = "nightvision-scanner"
}

variable "ec2_resource_tag_name" {
  description = "The name of the EC2 resource tag."
  type        = string
  default     = "nightvision-scheduled-scan"
}

variable "nightvision_token_secret_name" {
  description = "The name of the Nightvision API token secret."
  type        = string
  default     = "scheduled-scan-nightvision-token"
}

variable "instance_type" {
  description = "The instance type to use for the scanner."
  type        = string
  default     = "t3.small"
}

# ---------------------------------------------------------------------------------------------------------------------
# Values
# ---------------------------------------------------------------------------------------------------------------------
variable "nightvision_token" {
  type      = string
  sensitive = true
  description = "The Nightvision API token that will be used to run scans."
}

# ---------------------------------------------------------------------------------------------------------------------
# Lambda function arguments
# ---------------------------------------------------------------------------------------------------------------------
variable "runtime" {
  description = "The Python runtime"
  type = string
  default = "python3.11"
}

variable "output_path" {
  description = "Path to function's deployment package into local filesystem. eg: /path/lambda_function.zip"
  default = "lambda_function.zip"
}

variable "distribution_pkg_folder" {
  description = "Folder name to create distribution files..."
  default = "dist"
}

variable "path_source_code" {
  default = "lambda_function"
}
