#!/bin/bash

# Docker for Ubuntu
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

echo 'apt-get update'
sudo apt-get update -y

echo 'apt-get install'
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo 'sudo apt-key fingerprint 0EBFCD88'
sudo apt-key fingerprint 0EBFCD88

echo 'apt-get update'
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo 'apt-get update'
sudo apt-get update -y

echo 'sudo apt-get install -y docker-ce docker-ce-cli containerd.io'
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo 'sudo docker run hello-world'
sudo docker run hello-world