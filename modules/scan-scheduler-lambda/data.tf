data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-kernel-5.10-hvm-2.0.20240719.0-x86_64-gp2",
      # "amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2",
    ]
  }
}

# Store the AWS account_id in a variable so we can reference it in our IAM policy
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
