locals {
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
  project           = "kinnaird"
  scan_schedules = [
    {
      schedule_name     = "scan-javaspringvulny-web"
      application       = "javaspringvulny-web"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
      target            = "javaspringvulny-web"
      auth              = "javaspringvulny-web"
    },
    {
      schedule_name     = "scan-testphp"
      application       = "testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
      target            = "testphp"
    }
    // Add more schedules as needed
  ]
}