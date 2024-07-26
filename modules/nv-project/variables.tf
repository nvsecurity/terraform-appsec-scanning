variable "project_name" {
  type        = string
  description = "The name of the NightVision project"
}

variable "nightvision_token" {
  type        = string
  sensitive   = true
  description = "The Nightvision API token."
}