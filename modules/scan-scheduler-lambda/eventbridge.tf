/*# Create our schedule
resource "aws_cloudwatch_event_rule" "demo_lambda_every_5_minutes" {
  name                = "demo-lambda-every-5-minutes"
  description         = "Fires every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

# Trigger our lambda_function based on the schedule
resource "aws_cloudwatch_event_target" "trigger_lambda_on_schedule" {
  rule      = aws_cloudwatch_event_rule.demo_lambda_every_5_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.scheduled_scan.arn
}
*/

#
# resource "aws_lambda_permission" "allow_cloudwatch_to_call_split_lambda" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.scheduled_scan.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.demo_lambda_every_5_minutes.arn
# }
