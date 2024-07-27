/*
IAM Role that EventBridge Scheduler will use for the target when the schedule
is invoked.

https://docs.aws.amazon.com/scheduler/latest/UserGuide/setting-up.html#setting-up-execution-role
 */

resource "aws_iam_role" "scheduler" {
  name = var.scheduler_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "scheduler.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

data "aws_iam_policy_document" "scheduler" {
  statement {
    sid    = "InvokeLambda"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      aws_lambda_function.scanner_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "scheduler" {
  name        = "NightVisionSchedulerPolicy"
  description = "Policy for EventBridge Scheduler to invoke the NightVision Lambda function."
  policy      = data.aws_iam_policy_document.scheduler.json
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler.arn
}