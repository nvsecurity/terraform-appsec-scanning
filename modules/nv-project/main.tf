resource "null_resource" "nightvision_project" {
  triggers = {
    project_name       = var.project_name
    nightvision_token = var.nightvision_token
  }

  provisioner "local-exec" {
    when    = create
    command = "nightvision project create --name ${self.triggers.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    on_failure = continue
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "nightvision project delete --project ${self.triggers.project_name}"
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
}
