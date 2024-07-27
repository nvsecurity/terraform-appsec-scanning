locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

# This will schedule scans every 7 days
module "weekly_scans" {
  source               = "../../"
  nightvision_token    = var.nightvision_token
  create_scanner_infra = true
  scan_configs         = local.scan_configs
  create_project_name  = local.project
  web_targets          = local.web_targets
  openapi_code_targets = local.openapi_code_targets
  openapi_file_targets = local.openapi_file_targets
  openapi_url_targets  = local.openapi_url_targets
}
