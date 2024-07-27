module "scan_infrastructure" {
  source               = "../../"
  nightvision_token    = var.nightvision_token
  create_scanner_infra = true
  region               = "us-east-1"
}
