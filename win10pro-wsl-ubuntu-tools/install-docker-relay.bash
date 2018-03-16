#! /bin/bash

# reference: https://blogs.msdn.microsoft.com/commandline/2017/12/08/cross-post-wsl-interoperability-with-docker/

export GO_VERSION=1.9.4
echo "Installing go $GO_VERSION"
wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo "Installing the relay program"
go get -d github.com/jstarks/npiperelay
GOOS=windows go build -o /mnt/c/Users/${USER}/go/bin/npiperelay.exe github.com/jstarks/npiperelay
sudo ln -s /mnt/c/Users/${USER}/go/bin/npiperelay.exe /usr/local/bin/npiperelay.exe

echo "Installing Docker CE and socat"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install socat docker-ce

echo "Installing Docker Compose"
export COMPOSE_VERSION=1.19.0
sudo curl -L \
  https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Creating local relay daemon script"
cp docker-relay ~/docker-relay
chmod +x ~/docker-relay

echo "Adding $USER to the docker group"
sudo adduser $USER docker

echo "Adding 'docker-compose' alias to '$HOME/.bashrc'"
echo "alias docker-compose=docker-compose.exe" >> $HOME/.bashrc

echo "Close this session and open another to activate 'docker' group membership."
