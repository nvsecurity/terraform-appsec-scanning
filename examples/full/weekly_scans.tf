locals {
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-testphp-full-web"
      target            = "testphp-full-web"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    # API Scan - Swagger generated from analyzing code
    {
      schedule_name     = "scan-broken-flask-full-code"
      target            = "broken-flask-full-code"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    # API Scan - local Swagger file
    {
      schedule_name     = "scan-broken-flask-full-file"
      target            = "broken-flask-full-file"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    # API Scan - Swagger from a public URL
    {
      schedule_name     = "scan-jsv-api-full-url"
      target            = "jsv-api-full-url"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
