
# Lambda IAM Role
resource "aws_iam_role" "scheduled_scan" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

data "aws_iam_policy_document" "scheduled_scan_lambda" {
  statement {
    sid    = "EC2Describe"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "EC2CreateVolume"
    effect = "Allow"

    actions = [
      "ec2:CreateVolume"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        var.ec2_resource_tag_name
      ]
    }
  }

  statement {
    sid    = "EC2RunInstances"
    effect = "Allow"

    actions = [
      "ec2:RunInstances"
    ]

    resources = [
      aws_launch_template.nv_scanner.arn,
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:${data.aws_region.current.name}::image/*"
    ]
  }

  statement {
    sid    = "EC2CreateDeleteNetworkInterface"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]
  }

  statement {
    sid    = "EC2RunInstancesWithTag"
    effect = "Allow"

    actions = [
      "ec2:RunInstances"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        var.ec2_resource_tag_name,
        var.launch_template_name
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:LaunchTemplate"

      values = [
        aws_launch_template.nv_scanner.arn
      ]
    }
  }

  statement {
    sid    = "EC2InstanceVolumeActions"
    effect = "Allow"

    actions = [
      "ec2:DeleteVolume",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        var.ec2_resource_tag_name
      ]
    }
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.nv_scanner.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ec2.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "EC2AttachDetachVolume"
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume"
    ]

    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:volume/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        var.ec2_resource_tag_name
      ]
    }
  }

  statement {
    sid    = "EC2CreateTags"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:*/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"

      values = [
        var.ec2_resource_tag_name
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"

      values = [
        "CreateVolume",
        "RunInstances"
      ]
    }
  }
}

resource "aws_iam_policy" "scheduled_scan_lambda" {
  name   = "scheduled-scan-lambda-policy"
  policy = data.aws_iam_policy_document.scheduled_scan_lambda.json
}

resource "aws_iam_role_policy_attachment" "scheduled_scan_lambda" {
  policy_arn = aws_iam_policy.scheduled_scan_lambda.arn
  role       = aws_iam_role.scheduled_scan.name
}

resource "aws_iam_role_policy_attachment" "scheduled_scan_lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.scheduled_scan.name
}

resource "aws_iam_role_policy_attachment" "xray_write_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = aws_iam_role.scheduled_scan.name
}