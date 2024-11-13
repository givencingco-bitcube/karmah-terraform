data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "github-amplify-token"
}

locals {
 github_token = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string).access_token
}


