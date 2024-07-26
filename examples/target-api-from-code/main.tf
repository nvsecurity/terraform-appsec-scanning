module "target_api" {
  source            = "../../modules/nv-target-openapi-from-code"
  nightvision_token = var.nightvision_token
  target_name       = "broken-flask-api-extracted"
  url               = "https://flask.brokenlol.com"
  project_name      = "kinnaird"
  analyze_code_path = "${abspath(path.module)}/flask_app"
  language          = "python"
}

variable "nightvision_token" {
  sensitive =  true
}
