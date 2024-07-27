resource "aws_scheduler_schedule" "scan" {
  name = var.schedule_name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression

  target {
    arn      = var.scanner_lambda_arn
    role_arn = var.scheduler_role_arn

    input = jsonencode({
      subnet_id         = var.subnet_id
      security_group_id = var.security_group_id
      target            = var.target
      project           = var.project
      application       = var.target
      auth              = var.auth != null ? var.auth : null
    })
  }
}
