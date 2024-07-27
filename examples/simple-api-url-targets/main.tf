locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

module "api_scans" {
  source                 = "../../"
  nightvision_token      = var.nightvision_token
  scan_configs           = local.scan_configs
  openapi_url_targets = local.openapi_url_targets
  create_scanner_infra   = false
}

locals {
  openapi_url_targets = [
    {
      target_name        = "jsv-api-from-url"
      project            = local.project
      url                = "https://javaspringvulny.nvtest.io:9000/"
      openapi_public_url = "https://raw.githubusercontent.com/vulnerable-apps/javaspringvulny/main/openapi.yaml"
    }
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-jsv-api-from-url"
      target            = "jsv-api-from-url"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
