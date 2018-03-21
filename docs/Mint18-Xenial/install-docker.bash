#! /bin/bash

echo "Installing Docker CE"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt-get update && sudo apt-get install docker-ce

echo "Installing Docker Compose"
export COMPOSE_VERSION=1.19.0
sudo curl -L \
  https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Adding $USER to the docker group"
sudo adduser $USER docker

echo "Enabling and starting the Docker service"
sudo systemctl enable docker.service
sudo systemctl start docker.service

echo "Close this session and open another to activate 'docker' group membership."
