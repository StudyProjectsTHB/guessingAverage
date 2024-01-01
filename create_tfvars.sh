#!/bin/bash

TerraformFolderPath="terraform"
FilePath="$TerraformFolderPath/variables.auto.tfvars"

if [ -f "$FilePath" ]; then
    echo "$FilePath already exists."
else
    cat > "$FilePath" <<EOF
aws_credentials = {
  "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
  "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
  "aws_session_token": "YOUR_AWS_SESSION_TOKEN",
  "aws_db_password": "DB_PASSWORD",
  "aws_db_user": "DB_USER",
  "aws_ec2_public_key": "ssh-rsa YOUR_PUBLIC_KEY",
}

github_credentials = {
  "github_token": "YOUR_GITHUB_TOKEN",
  "github_repository": "guessingAverage",
  "github_repository_owner": "eineOrganisation",
}
EOF
    echo "created $FilePath."
fi
