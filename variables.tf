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
    project             = string
    target              = string
    auth                = string
  }))
  default = []
}


variable "targets" {
  description = "List of targets to scan"
  type = list(object({
      url         = string
      target_name = string
      target_type = string
  }))
  default = []
}