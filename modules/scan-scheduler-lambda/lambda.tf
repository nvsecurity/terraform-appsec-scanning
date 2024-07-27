locals {
  lambda_function_dir = "${path.module}/lambda_function"
  build_dir           = "${path.module}/build"
  zip_file            = "lambda.zip"
  handler             = "handler.lambda_handler"
}

resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    when        = create
    command     = <<EOT
      mkdir -p build
      pip install -r ${self.triggers.lambda_function_dir}/requirements.txt -t ${self.triggers.build_dir}/
      cp -r ${self.triggers.lambda_function_dir}/* ${self.triggers.build_dir}/
    EOT
    working_dir = path.module
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.triggers.build_dir} ${self.triggers.zip_file}"
  }

  triggers = {
    lambda_directory_hash = sha256(join("", [for f in fileset(local.lambda_function_dir, "**/*") : filemd5("${local.lambda_function_dir}/${f}")]))
    build_dir             = local.build_dir
    zip_file              = local.zip_file
    lambda_function_dir   = local.lambda_function_dir
  }
}

data "archive_file" "create_dist_pkg" {
  depends_on  = [null_resource.build_lambda]
  source_dir  = "${local.build_dir}/"
  output_path = "${path.module}/${local.zip_file}"
  type        = "zip"
}


resource "aws_lambda_function" "scanner_lambda" {
  filename      = "${path.module}/${local.zip_file}"
  function_name = var.function_name
  role          = aws_iam_role.scheduled_scan.arn
  handler       = local.handler
  runtime       = var.runtime
  timeout       = 30
  tracing_config {
    mode = "Active"
  }
  source_code_hash = data.archive_file.create_dist_pkg.output_base64sha256
  depends_on       = [null_resource.build_lambda]
  environment {
    variables = {
      AWS_AMI_ID           = data.aws_ami.amazon_linux_2.id
      INSTANCE_TAG_NAME    = var.ec2_resource_tag_name
      INSTANCE_TYPE        = var.instance_type
      SECRET_NAME          = aws_secretsmanager_secret.nv_token.name
      LAUNCH_TEMPLATE_NAME = aws_launch_template.nv_scanner.name
    }
  }
  tags = {
    Name = var.function_name
  }
}
