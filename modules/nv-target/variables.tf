variable "url" {
  type        = string
  description = "The URL of the target to scan."
}

variable "project_name" {
  type        = string
  description = "The name of the NightVision project"
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

variable "target_type" {
  description = "The target type. Must be either 'web' or 'api'."
  type        = string
  validation {
    condition     = contains(["web", "api"], var.target_type)
    error_message = "The service_type variable must be either 'web' or 'api'."
  }
}