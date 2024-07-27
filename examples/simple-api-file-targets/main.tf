locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

module "weekly_scans" {
  source               = "../../"
  nightvision_token    = var.nightvision_token
  scan_configs         = local.scan_configs
  openapi_file_targets = local.openapi_file_targets
  create_scanner_infra = false
}

locals {
  openapi_file_targets = [
    {
      url               = "https://flask.brokenlol.com"
      project           = local.project
      target_name       = "broken-flask-from-file"
      openapi_file_path = "${abspath(path.module)}/broken-flask-openapi.yml"
    },
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-broken-flask-from-file"
      target            = "broken-flask-from-file"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
