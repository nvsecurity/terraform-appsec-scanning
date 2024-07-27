locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

# This will schedule scans every 7 days
module "weekly_scans" {
  source              = "../../"
  nightvision_token   = var.nightvision_token
  scan_configs        = local.scan_configs
  create_project_name = local.project
  web_targets         = local.web_targets
}

locals {
  web_targets = [
    {
      target_name = "testphp"
      project     = local.project
      url         = "http://testphp.vulnweb.com/"
    },
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-testphp"
      target            = "testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
