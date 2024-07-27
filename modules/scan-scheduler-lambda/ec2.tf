# Create a Launch template that can be used to create an EC2 instance for scanning
resource "aws_launch_template" "nv_scanner" {
  name = var.launch_template_name
  iam_instance_profile {
    name = aws_iam_instance_profile.nv_scanner.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 16
      volume_type = "gp2"
      delete_on_termination = true
    }
  }
  image_id = data.aws_ami.amazon_linux_2.id
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.ec2_resource_tag_name
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.ec2_resource_tag_name
    }
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name = var.ec2_resource_tag_name
    }
  }
}

resource "aws_iam_role" "nv_scanner" {
  name = var.scanner_instance_profile_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Create an instance profile
resource "aws_iam_instance_profile" "nv_scanner" {
  name = var.scanner_instance_profile_name
  role = aws_iam_role.nv_scanner.name
}

# Policy for the scanner instance profile
data "aws_iam_policy_document" "nv_scanner" {
  statement {
    effect = "Allow"
    sid = "NukeThyself"
    actions = [
      "ec2:DeleteVolume",
      "ec2:TerminateInstances",
      "ec2:StopInstances",
      "ec2:DetachVolume",
      "ec2:DeleteSnapshot",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values = [var.ec2_resource_tag_name]
      variable = "ec2:ResourceTag/Name"
    }
  }
  statement {
    sid = "GetNightVisionToken"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.nv_token.arn
    ]
  }
  statement {
    sid = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "nv_scanner" {
  name        = var.scanner_instance_profile_name
  policy      = data.aws_iam_policy_document.nv_scanner.json
  description = "Policy for the EC2 instance running NightVision scans."
}

resource "aws_iam_role_policy_attachment" "nv_scanner_policy" {
  policy_arn = aws_iam_policy.nv_scanner.arn
  role       = aws_iam_role.nv_scanner.name
}

resource "aws_iam_role_policy_attachment" "scanner_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nv_scanner.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.nv_scanner.name
}
