locals {
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-testphp"
      target            = "testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    {
      schedule_name     = "scan-javaspringvulny-web"
      target            = "javaspringvulny-web"
      auth              = "javaspringvulny-web"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    // Add more schedules as needed
  ]
}
