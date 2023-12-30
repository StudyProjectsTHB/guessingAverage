#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

sudo apt install ca-certificates curl gnupg lsb-release
sudo DEBIAN_FRONTEND=noninteractive apt install -y awscli

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io -y

sudo aws configure set region ${aws_region}

secret_value=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text)
db_host=$(echo "$secret_value" | awk -F'"host":' '{print $2}' | awk -F'"' '{print $2}')
db_name=$(echo "$secret_value" | awk -F'"db_name":' '{print $2}' | awk -F'"' '{print $2}')
db_username=$(echo "$secret_value" | awk -F'"username":' '{print $2}' | awk -F'"' '{print $2}')
db_password=$(echo "$secret_value" | awk -F'"password":' '{print $2}' | awk -F'"' '{print $2}')

sudo docker pull leonxs/guessing_average:latest
sudo docker run -e DATABASE_HOST=$(echo -n "$db_host" | tr -d '\n') -e DATABASE_NAME=$(echo -n "$db_name" | tr -d '\n') -e DATABASE_USER=$(echo -n "$db_username" | tr -d '\n') -e DATABASE_PASSWORD=$(echo -n "$db_password" | tr -d '\n') -e SERVER_PORT=8080 -p 80:8080 leonxs/guessing_average:latest