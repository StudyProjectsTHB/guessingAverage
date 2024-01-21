terraform{
  required_version = ">= 1.6.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.33.0"
        }
        github = {
            source = "integrations/github"
            version = "~> 5.42.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.6.0"
        }
        archive = {
            source = "hashicorp/archive"
            version = "~> 2.4.1"
        }
        template = {
            source = "hashicorp/template"
            version = "~> 2.2.0"
        }
        null = {
            source = "hashicorp/null"
            version = "~> 3.2.2"
        }
    }
}

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