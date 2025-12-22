#!/bin/bash
set -e

sudo yum install nginx -y
sudo yum install docker -y
sudo yum install golang -y

sudo systemctl enable nginx
sudo systemctl enable docker

sudo systemctl start docker
sudo systemctl start nginx

cat <<EOF > /etc/nginx/nginx.conf
${nginx_config}
EOF

sudo nginx -s reload

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

mkdir -p /home/ec2-user/database

cat <<EOF > /home/ec2-user/database/compose.yaml
${docker_compose}
EOF

cd /home/ec2-user/database
sudo docker-compose up -d

cd /home/ec2-user

sudo go install sigs.k8s.io/kind@v0.31.0
sudo mv /root/go/bin/kind /bin/kind
sudo chmod +x /bin/kind

sudo kind create cluster
