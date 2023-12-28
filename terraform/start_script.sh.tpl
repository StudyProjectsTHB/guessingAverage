#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

sudo apt install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io -y
sudo docker pull leonxs/guessing_average:latest
docker run -e DATABASE_HOST=${db_host} -e DATABASE_NAME=postgres -e DATABASE_USER=postgres -e DATABASE_PASSWORD=${db_password} -e SERVER_PORT=8080 -p 80:8080 leonxs/guessing_average:latest