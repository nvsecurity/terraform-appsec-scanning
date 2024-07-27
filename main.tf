data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  scanner_lambda_arn_calculated  = length(module.scheduler_lambda) > 0 ? module.scheduler_lambda[0].scanner_lambda_arn : "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.existing_scanner_lambda_name}"
  scheduler_role_arn_calculated  = length(module.scheduler_lambda) > 0 ? module.scheduler_lambda[0].scheduler_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.existing_scheduler_role_name}"
}

# Create a Lambda function that will be used to scan the target
module "scheduler_lambda" {
  source            = "./modules/scan-scheduler-lambda"
  count             = var.create_scanner_infra != false ? 1 : 0
  nightvision_token = var.nightvision_token
  region            = var.region
}

# Create NightVision projects
module "nightvision_project" {
  source            = "./modules/nv-project"
  count             = var.create_project_name != null ? 1 : 0
  project_name      = var.create_project_name
  nightvision_token = var.nightvision_token
}

# Schedule scans inside your VPC
module "scan_schedules" {
  source   = "./modules/scan-target-schedule"
  for_each = { for config in var.scan_configs : config.schedule_name => config }
  scanner_lambda_arn  = local.scanner_lambda_arn_calculated
  scheduler_role_arn  = local.scheduler_role_arn_calculated
  schedule_name       = each.value.schedule_name
  schedule_expression = try(each.value["schedule_expression"], null)
  project             = each.value.project
  security_group_id   = each.value.security_group_id
  subnet_id           = each.value.subnet_id
  target              = each.value.target
  auth                = try(each.value["auth"], null)

  depends_on = [module.scheduler_lambda, module.nightvision_project]
}

# Web Application Targets
module "web_targets" {
  source   = "./modules/nv-target-web"
  for_each = { for target in var.web_targets : target.target_name => target }

  nightvision_token = var.nightvision_token
  target_name       = each.value.target_name
  url               = each.value.url
  project_name      = each.value.project

  depends_on = [module.scheduler_lambda, module.nightvision_project]
}

# Create OpenAPI targets from publicly accessible OpenAPI files
module "openapi_url_targets" {
  source   = "./modules/nv-target-openapi-public-url"
  for_each = { for target in var.openapi_url_targets : target.target_name => target }

  nightvision_token  = var.nightvision_token
  target_name        = each.value.target_name
  url                = each.value.url
  project_name       = each.value.project
  openapi_public_url = each.value.openapi_public_url

  depends_on = [module.scheduler_lambda, module.nightvision_project]
}

# Create OpenAPI targets from locally accessible OpenAPI files
module "openapi_file_targets" {
  source   = "./modules/nv-target-openapi-file"
  for_each = { for target in var.openapi_file_targets : target.target_name => target }

  nightvision_token = var.nightvision_token
  target_name       = each.value.target_name
  openapi_file_path = each.value.openapi_file_path
  url               = each.value.url
  project_name      = each.value.project

  depends_on = [module.scheduler_lambda, module.nightvision_project]
}

# Create OpenAPI targets from analyzing code paths
module "openapi_code_targets" {
  source   = "./modules/nv-target-openapi-from-code"
  for_each = { for target in var.openapi_code_targets : target.target_name => target }

  nightvision_token = var.nightvision_token
  target_name       = each.value.target_name
  url               = each.value.url
  project_name      = each.value.project
  language          = each.value.language
  analyze_code_path = each.value.code_path

  depends_on = [module.scheduler_lambda, module.nightvision_project]
}
