locals {
  web_targets = [
    {
      target_name = "testphp-full-web"
      project     = local.project
      url         = "http://testphp.vulnweb.com/"
    },
  ]
  # API Scan - Swagger generated from analyzing code
  openapi_code_targets = [
    {
      target_name = "broken-flask-full-code"
      project     = local.project
      url         = "https://flask.brokenlol.com"
      language    = "python"
      code_path   = "${abspath(path.module)}/../flask_app"
    },
  ]
  # API Scan - local Swagger file
  openapi_file_targets = [
    {
      url               = "https://flask.brokenlol.com"
      project           = local.project
      target_name       = "broken-flask-full-file"
      openapi_file_path = "${abspath(path.module)}/broken-flask-openapi.yml"
    },
  ]
  # API Scan - Swagger from a public URL
  openapi_url_targets = [
    {
      target_name        = "jsv-api-full-url"
      project            = local.project
      url                = "https://javaspringvulny.nvtest.io:9000/"
      openapi_public_url = "https://raw.githubusercontent.com/vulnerable-apps/javaspringvulny/main/openapi.yaml"
    }
  ]
}