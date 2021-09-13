#!/bin/bash
echo '=============== Staring init script for Secrets Manager API ==============='

# save all env for debugging
printenv > /var/log/colony-vars-"$(basename "$BASH_SOURCE" .sh)".txt

echo '==> Installing Node.js and NPM'
sudo apt-get update
sudo apt install curl -y

echo '==> Extract api artifact to /var/secrets-manager-api'
mkdir $ARTIFACTS_PATH/drop
tar -xvf $ARTIFACTS_PATH/api.*.tar.gz -C $ARTIFACTS_PATH/drop/
mkdir /var/secrets-manager-api/
tar -xvf $ARTIFACTS_PATH/drop/drop/api.*.tar.gz -C /var/secrets-manager-api

echo 'RELEASE_NUMBER='$RELEASE_NUMBER >> /etc/environment
echo 'API_BUILD_NUMBER='$API_BUILD_NUMBER >> /etc/environment
echo 'API_PORT='$API_PORT >> /etc/environment
source /etc/environment

echo '==> Start our api and configure as a daemon using pm2'
cd /var/secrets-manager-api
start AWS.SecretMgr
