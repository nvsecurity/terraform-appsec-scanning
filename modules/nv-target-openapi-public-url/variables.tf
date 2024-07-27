# ---------------------------------------------------------------------------------------------------------------------
# API Target specific arguments
# ---------------------------------------------------------------------------------------------------------------------
variable "openapi_public_url" {
  description = "The public URL to a Swagger file."
  type        = string
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
