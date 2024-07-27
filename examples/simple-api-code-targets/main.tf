locals {
  project                     = "terraform-example"
  security_group_id           = "sg-0839aeaccdda71f96"
  subnet_id                   = "subnet-07a080852c0769a32"
}

module "weekly_scans" {
  source                      = "../../"
  nightvision_token           = var.nightvision_token
  scan_configs                = local.scan_configs
  openapi_code_targets        = local.openapi_code_targets
  create_scanner_infra        = false
}

locals {
  openapi_code_targets = [
    {
      target_name = "broken-flask-extracted"
      project     = local.project
      url         = "https://flask.brokenlol.com"
      language    = "python"
      code_path   = "${abspath(path.module)}/flask_app"
    },
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-broken-flask"
      target            = "broken-flask-extracted"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
