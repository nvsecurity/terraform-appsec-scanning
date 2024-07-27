resource "aws_secretsmanager_secret" "nv_token" {
  name_prefix = var.nightvision_token_secret_name
}

resource "aws_secretsmanager_secret_version" "nv_token" {
  secret_id     = aws_secretsmanager_secret.nv_token.id
  secret_string = var.nightvision_token
}