#!/bin/bash

TerraformFolderPath="terraform"
FilePath="$TerraformFolderPath/variables.auto.tfvars"

if [ -f "$FilePath" ]; then
    echo "$FilePath already exists."
else
    cat > "$FilePath" <<EOF
aws_credentials = {
  "access_key": "YOUR_AWS_ACCESS_KEY_ID",
  "secret_key": "YOUR_AWS_SECRET_ACCESS_KEY",
  "token": "YOUR_AWS_SESSION_TOKEN",
  "db_password": "DB_PASSWORD",
  "db_user": "DB_USER",
  "public_key": "ssh-rsa YOUR_PUBLIC_KEY",
}

github_credentials = {
  "token": "YOUR_GITHUB_TOKEN",
  "repository": "guessingAverage",
  "owner": "eineOrganisation",
}
EOF
    echo "created $FilePath."
fi
