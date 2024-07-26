module "target_api" {
  source            = "../../modules/nv-target-openapi-file"
  nightvision_token = var.nightvision_token
  openapi_file_path = "${abspath(path.module)}/broken-flask-openapi.yml"
  target_name       = "broken-flask-api"
  url               = "https://flask.brokenlol.com"
  project_name      = "kinnaird"
}

variable "nightvision_token" {
  sensitive =  true
}
