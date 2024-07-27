# This module creates the target in NightVision
module "target_general" {
  source            = "../nv-target"
  nightvision_token = var.nightvision_token
  target_name       = var.target_name
  target_type       = "api"
  url               = var.url
  project_name      = var.project_name
}

# Uploads an OpenAPI file to the NightVision API
resource "null_resource" "target_openapi_url" {
  depends_on = [module.target_general]

  triggers = {
    target_name        = var.target_name
    url                = var.url
    nightvision_token  = var.nightvision_token
    openapi_public_url = var.openapi_public_url
    project_name       = var.project_name
  }

  provisioner "local-exec" {
    when    = create
    command = "nightvision target update --target ${self.triggers.target_name} --url ${self.triggers.url} --swagger-url ${self.triggers.openapi_public_url} --project ${var.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
}
