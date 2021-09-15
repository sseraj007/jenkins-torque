#!/usr/bin/env bash
DOCKERFILE_REPO="https://github.com/sseraj007/torque-jenkins-dockerized.git"
DOCKER_COMPOSE_VER="1.26.2"
WORKDIR="/tmp/jenkins"
COLONY_PLUGIN_URL="https://github.com/cloudshell-colony/jenkins-plugin/releases/latest/download/colony.hpi"

set -o errexit
set -o nounset

# Installing .net SDK and Runtime
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y dotnet-sdk-3.1
sudo apt-get update;
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y aspnetcore-runtime-3.1


echo "==> Starting deployment"

# Docker
apt update
apt --yes --no-install-recommends install apt-transport-https ca-certificates git
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
apt update
apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
# usermod --append --groups docker "$USER"
systemctl enable docker
sleep 5
echo "==> docker installed successfully"


# Docker Compose
wget --output-document=/usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/run.sh
chmod +x /usr/local/bin/docker-compose
wget --output-document=/etc/bash_completion.d/docker-compose "https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose"
echo "==> compose installed successfully"


# Jenkins
echo "==> Cloning jenkins installation repo"
git clone ${DOCKERFILE_REPO} ${WORKDIR}

echo "==> Setting admin password"
sed -i "s/%PASSWORD%/${JENKINS_ADMIN_PASS}/g" ${WORKDIR}/master/Dockerfile

echo "==> Preparing a job"
sed -i "s/%SPACE%/${SPACE_NAME}/g" ${WORKDIR}/master/config.xml
sed -i "s/%BUCKET_NAME%/${BUCKET_NAME}/g" ${WORKDIR}/master/config.xml

echo "==> Preparing a CasC config"
sed -i "s|%TOKEN%|${CS_TORQUE_TOKEN}|g" ${WORKDIR}/master/jenkins.yaml

echo "==> Downloading a plugin file"
wget --no-check-certificate ${COLONY_PLUGIN_URL} -O ${WORKDIR}/master/colony.hpi

echo "==> Starting jenkins"
cd ${WORKDIR}
docker-compose -f jenkins-docker-compose.yml up -d --build --force-recreate

rm -rf ${WORKDIR}
