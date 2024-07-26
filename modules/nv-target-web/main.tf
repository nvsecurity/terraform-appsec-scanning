# This module creates the target in NightVision
module "target_general" {
  source            = "../nv-target"
  nightvision_token = var.nightvision_token
  target_name       = var.target_name
  target_type       = "web"
  url               = var.url
  project_name      = var.project_name
}
