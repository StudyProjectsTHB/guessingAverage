provider "aws" {
 region = var.aws_region
 access_key = var.aws_credentials["aws_access_key_id"]
 secret_key = var.aws_credentials["aws_secret_access_key"]
 token = var.aws_credentials["aws_session_token"]
}

provider "github" {
 token = var.github_credentials["github_token"]
 owner = var.github_credentials["github_repository_owner"]
}