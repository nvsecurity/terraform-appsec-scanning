# ---------------------------------------------------------------------------------------------------------------------
# API Target specific arguments
# ---------------------------------------------------------------------------------------------------------------------
variable "analyze_code_path" {
  description = "The path to the code base where NightVision will try to extract an OpenAPI/Swagger doc."
  type        = string
}

variable "language" {
  description = "Programming language of the code base to extract."
  type        = string

  validation {
    condition     = contains(["java", "javascript", "python", "dotnet", "go"], var.language)
    error_message = "The language must be one of 'java', 'javascript', 'python', 'dotnet', or 'go'."
  }
}

variable "exclude_paths" {
  description = "Paths to exclude from analysis"
  type        = list(string)
  default     = ["vendor/*", "*.json"]
}

# ---------------------------------------------------------------------------------------------------------------------
# General target arguments
# ---------------------------------------------------------------------------------------------------------------------
variable "url" {
  type        = string
  description = "The URL of the target to scan."
}

variable "nightvision_token" {
  type        = string
  sensitive   = true
  description = "The Nightvision API token."
}

variable "target_name" {
  type = string
  validation {
    condition     = can(regex("^[-_a-zA-Z0-9]+$", var.target_name))
    error_message = "The target_name variable must contain only alphanumeric characters, hyphens (-), and underscores (_)."
  }
}

variable "project_name" {
  type        = string
  description = "The name of the NightVision project"
}
