data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = "java-app"
}

locals {
  db_secret_json = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)

  db_user     = local.db_secret_json["DB_USER"]
  db_password = local.db_secret_json["DB_PASS"]
  db_name     = local.db_secret_json["DB_NAME"]
}

data "aws_db_instance" "existing" {
  db_instance_identifier = var.db_identifier
}