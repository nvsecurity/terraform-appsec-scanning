module "nightvision_project" {
  source               = "../../"
  create_project_name  = "terraform-example"
  nightvision_token    = var.nightvision_token
  create_scanner_infra = false
}
