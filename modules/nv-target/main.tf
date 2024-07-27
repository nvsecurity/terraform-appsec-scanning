resource "terraform_data" "replacement" {
  input = [
    var.target_name,
    var.url,
    var.project_name,
    var.target_type
  ]
}


resource "null_resource" "nightvision_target" {
  triggers = {
    target_name       = var.target_name
    url               = var.url
    nightvision_token = var.nightvision_token
    target_type       = var.target_type
    project_name      = var.project_name
  }

  provisioner "local-exec" {
    when    = create
    command = "nightvision target create --name ${self.triggers.target_name} --url ${self.triggers.url} --type ${self.triggers.target_type} --project ${self.triggers.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    on_failure = continue
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "nightvision target delete --target ${self.triggers.target_name} --project ${self.triggers.project_name}"
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      terraform_data.replacement
    ]
  }
}

resource "null_resource" "nightvision_application" {
  triggers = {
    target_name       = var.target_name
    url               = var.url
    nightvision_token = var.nightvision_token
    target_type       = var.target_type
    project_name      = var.project_name
  }
  provisioner "local-exec" {
    when    = create
    command = "nightvision app create --name ${self.triggers.target_name} --project ${self.triggers.project_name}"
    # If it runs on update, the target will already be created so it will throw exit code 1.
    # If that's the case, we can ignore it
    on_failure = continue
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "nightvision app delete --app ${self.triggers.target_name} --project ${self.triggers.project_name}"
    environment = {
      NIGHTVISION_TOKEN = self.triggers.nightvision_token
    }
  }
  lifecycle {
    create_before_destroy = false
    replace_triggered_by = [
      terraform_data.replacement
    ]
  }
}