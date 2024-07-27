locals {
  web_targets = [
    {
      target_name = "testphp"
      project     = local.project
      url         = "http://testphp.vulnweb.com/"
    },
    {
      target_name = "javaspringvulny-web"
      project     = local.project
      url         = "https://javaspringvulny.nvtest.io:9000/"
    },
    // Add more targets as needed
  ]

  public_api_targets = [
    {
      target_name        = "javaspringvulny-api"
      project            = local.project
      url                = "https://javaspringvulny.nvtest.io:9000/"
      openapi_public_url = "https://raw.githubusercontent.com/vulnerable-apps/javaspringvulny/main/openapi.yaml"
    }
  ]
  openapi_file_targets = []
  openapi_code_targets = []
  #     openapi_file_targets = [
  #         {
  #         target_name = "openapi-file"
  #         target_url  = "https://javaspringvulny.nvtest.io:9000/"
  #         openapi_file_path = "openapi.json"
  #         }
  #     ]
  #
  #     openapi_code_targets = [
  #         {
  #         target_name = "openapi-code"
  #         target_url  = "https://javaspringvulny.nvtest.io:9000/"
  #         language = "java"
  #         code_path = "src/main/java"
  #         }
  #     ]
}