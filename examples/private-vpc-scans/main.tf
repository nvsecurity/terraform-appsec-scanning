module "scheduler" {
  source            = "../../modules/scan-scheduler-lambda"
  nightvision_token = var.nightvision_token
}

module "scan_schedules" {
  source   = "../../modules/scan-target-schedule"
  for_each = { for config in var.scan_configs : config.schedule_name => config }

  scanner_lambda_arn  = module.scheduler.scanner_lambda_arn
  scheduler_role_arn  = module.scheduler.scheduler_role_arn
  schedule_name       = each.value.schedule_name
  application         = each.value.application
  schedule_expression = each.value.schedule_expression
  project             = each.value.project
  security_group_id   = each.value.security_group_id
  subnet_id           = each.value.subnet_id
  target              = each.value.target
  auth                = each.value.auth
}
