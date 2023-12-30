provider "aws" {
 region = var.aws_region
 access_key = var.aws_credentials["access_key"]
 secret_key = var.aws_credentials["secret_key"]
 token = var.aws_credentials["token"]
}

provider "github" {
 token = var.github_credentials["token"]
 owner = var.github_credentials["owner"]
}