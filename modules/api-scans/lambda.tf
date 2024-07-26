data "archive_file" "python_lambda_package" {
  type = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "function.zip"
}

# Create out lambda, using a locally sourced zip file
resource "aws_lambda_function" "demo_lambda_hello_world" {
  function_name = "demo-lambda-hello-world"
  role          = aws_iam_role.demo_lambda_role.arn
  package_type  = "Zip"
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"

  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  depends_on = [
    aws_iam_role.demo_lambda_role
  ]

  tags = {
    Name = "Demo Lambda Hello World"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_split_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo_lambda_hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.demo_lambda_every_5_minutes.arn
}
