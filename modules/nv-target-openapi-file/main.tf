# This module creates the target in NightVision
module "target_general" {
  source            = "../nv-target"
  nightvision_token = var.nightvision_token
  target_name       = var.target_name
  target_type       = "api"
  url               = var.url
  project_name      = var.project_name
}

# Read the file and check if the contents update
locals {
  openapi_file_md5 = filemd5(var.openapi_file_path)
}

# Terraform's variable validation cannot directly check the existence of a file on the local
# filesystem because it doesn't have built-in functions to perform file system operations.
# However, you can achieve this with a combination of Terraform and an external script executed via a
# local-exec provisioner.
resource "null_resource" "validate_openapi_file" {
  provisioner "local-exec" {
    command = "test -f ${var.openapi_file_path} || (echo 'File does not exist: ${var.openapi_file_path}' && exit 1)"
  }
}

# Uploads an OpenAPI file to the NightVision API
resource "null_resource" "target_openapi_file" {
  depends_on = [module.target_general]

  triggers = {
    target_name       = var.target_name
    openapi_file_md5  = local.openapi_file_md5
    url               = var.url
    nightvision_token = var.nightvision_token
    openapi_file_path = var.openapi_file_path
    project_name      = var.project_name
  }

  provisioner "local-exec" {
    when    = create
    command = "nightvision target update --target ${self.triggers.target_name} --url ${self.triggers.url} --swagger-file ${self.triggers.openapi_file_path} --project ${var.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
}
