variable "aws_region" {
 description = "Region to use for AWS resources"
 type = string
 default = "us-east-1"
 sensitive = false
}

variable "num_public_subnets" {
 description = "Number of public subnets in VPC"
 type = number
 default = 2
}

variable "num_private_subnets" {
 description = "Number of private subnets in VPC"
 type = number
 default = 2
}

variable "db_name" {
 description = "Name of DB"
 type = string
 default = "guessingAverage"
}

variable "github_webhook_route" {
 description = "Route for API Gateway to use for GitHub Webhook"
 type = string
 default = "github-webhook"
}

variable "aws_credentials" {
 type = map(string)  # keys: "aws_access_key_id", "aws_secret_access_key", "aws_session_token", "aws_db_password", "aws_db_user", "aws_ec2_public_key"
}

variable "github_credentials" {
 type = map(string)  # keys: "github_token", "github_repository", "github_owner"
}
