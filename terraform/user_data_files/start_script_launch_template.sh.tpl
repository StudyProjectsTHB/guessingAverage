#!/bin/bash

aws configure set region ${aws_region}

secret_value=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text)
db_host=$(echo "$secret_value" | awk -F'"host":' '{print $2}' | awk -F'"' '{print $2}')
db_name=$(echo "$secret_value" | awk -F'"db_name":' '{print $2}' | awk -F'"' '{print $2}')
db_username=$(echo "$secret_value" | awk -F'"username":' '{print $2}' | awk -F'"' '{print $2}')
db_password=$(echo "$secret_value" | awk -F'"password":' '{print $2}' | awk -F'"' '{print $2}')

sudo docker run -e DATABASE_HOST=$(echo -n "$db_host" | tr -d '\n') -e DATABASE_NAME=$(echo -n "$db_name" | tr -d '\n') -e DATABASE_USER=$(echo -n "$db_username" | tr -d '\n') -e DATABASE_PASSWORD=$(echo -n "$db_password" | tr -d '\n') -e SERVER_PORT=8080 -p 80:8080 ${docker_repository}