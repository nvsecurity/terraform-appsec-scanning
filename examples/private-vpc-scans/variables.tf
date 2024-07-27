variable "nightvision_token" {
  description = "NightVision API token"
  sensitive   = true
}

variable "scan_configs" {
  description = "List of scan configs"
  type = list(object({
    # AWS Arguments
    schedule_name       = string
    schedule_expression = string
    # AWS Resources
    security_group_id   = string
    subnet_id           = string
    # NightVision Constructs
    application         = string
    project             = string
    target              = string
    auth                = string
  }))
  default = []
}