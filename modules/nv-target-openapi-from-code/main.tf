# This module creates the target in NightVision
module "target_general" {
  source            = "../nv-target"
  nightvision_token = var.nightvision_token
  target_name       = var.target_name
  target_type       = "api"
  url               = var.url
  project_name      = var.project_name
}

data "external" "directory_hash" {
  program = ["${abspath(path.module)}/hash_directory.sh", var.analyze_code_path]
}

# Scans code and uploads generated Swagger file to the NightVision API
resource "null_resource" "swagger_extraction" {
  depends_on = [module.target_general]

  triggers = {
    target_name               = var.target_name
    url                       = var.url
    nightvision_token         = var.nightvision_token
    extract_openapi_from_path = var.analyze_code_path
    project_name              = var.project_name
    language                  = var.language
  }

  provisioner "local-exec" {
    when    = create
    # nightvision swagger extract ./ -o openapi-spec.yml -t javaspringvulny-api -l java
    command = "nightvision swagger extract ${self.triggers.extract_openapi_from_path} --output ${path.root}/openapi-spec.yml --target ${self.triggers.target_name} --lang ${self.triggers.language} --project ${var.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
}

# TODO: Calculate the following flags based on user input:
# --config: path to config file that has the unresolved route prefix in it
# --exclude --exclude=vendor/*,*.json   Exclude files or directories from the analysis, e.g. --exclude=vendor/*,*.json
