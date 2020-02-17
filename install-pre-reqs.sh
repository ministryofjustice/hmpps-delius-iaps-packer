#!/bin/bash

# Docker for Ubuntu
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

echo 'Running: apt-get update'
apt-get update -y

echo 'Running: apt-get install'
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo 'Running: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo 'Running: apt-key fingerprint 0EBFCD88'
apt-key fingerprint 0EBFCD88

echo 'Running: apt-get update'
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo 'Running: apt-get update'
apt-get update -y

echo 'Running: apt-get install -y docker-ce docker-ce-cli containerd.io'
apt-get install -y docker-ce docker-ce-cli containerd.io

echo 'Running: docker run hello-world'
docker run hello-world

# docker-compose
apt-get install wget -y

wget https://github.com/docker/compose/releases/download/1.21.2/docker-compose-Linux-x86_64 -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
/usr/bin/docker-compose -v 