# Create our schedule
resource "aws_cloudwatch_event_rule" "demo_lambda_every_5_minutes" {
  name                = "demo-lambda-every-5-minutes"
  description         = "Fires every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

# Trigger our lambda based on the schedule
resource "aws_cloudwatch_event_target" "trigger_lambda_on_schedule" {
  rule      = aws_cloudwatch_event_rule.demo_lambda_every_5_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.demo_lambda_hello_world.arn
}
