#!/bin/bash
echo '=============== Staring init script for Secrets Manager API ==============='

# save all env for debugging
printenv > /var/log/colony-vars-"$(basename "$BASH_SOURCE" .sh)".txt

# Install dotnet core and dependencies
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install the .Net Core framework, set the path, and show the version of core installed.
apt-get install -y apt-transport-https
apt-get update
apt-get install -y dotnet-sdk-3.1 && \
    export PATH=$PATH:$HOME/dotnet && \
    dotnet --version
apt-get update
apt-get install -y aspnetcore-runtime-3.1


# echo '==> Installing Apache'
# sudo apt update
# echo 'Updated'
# sudo apt install -y apache2
# echo 'Installed Apache'
# sudo ufw app list
# sudo ufw allow 'Apache'
# sudo ufw status
# sudo systemctl enable apache2
# sudo systemctl start apache2
# sudo systemctl status apache2

echo '===> Installing Nginx'
sudo apt update
sudo apt install -y nginx
sudo service nginx start

cd /etc/nginx/sites-available
cat << EOF > default
server {
    listen        3001;
    server_name   *.com;
    root /var/www/secrets-manager-api;
    location / {
        proxy_pass         http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF

echo 'sites available modified'

sudo nginx -s reload

echo 'reload successful'

cd /etc/systemd/system
cat << EOF > kestrel-secret-manager-api.service
[Unit]
Description=Secrets Manager API
[Service]
WorkingDirectory=/var/www/secrets-manager-api
ExecStart=/usr/bin/dotnet /var/www/secrets-manager-api/AWS.SecretMgr.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
[Install]
WantedBy=multi-user.target
EOF

echo 'service created'

sudo systemctl enable kestrel-secret-manager-api.service
sudo systemctl start kestrel-secret-manager-api.service

sudo systemctl statuss kestrel-secret-manager-api.service


echo '==> Extract api artifact to /var/www/secrets-manager-api'
mkdir $ARTIFACTS_PATH/drop
tar -xvf $ARTIFACTS_PATH/secrets-manager-api.tar.gz -C $ARTIFACTS_PATH/drop/
mkdir /var/www/secrets-manager-api/
tar -xvf $ARTIFACTS_PATH/drop/drop/secrets-manager-api.tar.gz -C /var/www/secrets-manager-api

echo 'RELEASE_NUMBER='$RELEASE_NUMBER >> /etc/environment
echo 'API_BUILD_NUMBER='$API_BUILD_NUMBER >> /etc/environment
echo 'API_PORT='$API_PORT >> /etc/environment
source /etc/environment
