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


sudo docker pull ${docker_repository}
