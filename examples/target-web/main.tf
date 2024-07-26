module "target_web" {
  source            = "../../modules/nv-target"
  nightvision_token = var.nightvision_token
  target_name       = "javaspringvulny-web5"
  url               = "https://javaspringvulny.nvtest.io:9000/"
  project_name      = "kinnaird"
  target_type       = "web"
}

variable "nightvision_token" {
  sensitive =  true
}
