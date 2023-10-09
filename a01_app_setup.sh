#!/bin/bash
source state_file.txt

KEY_FILE="Assignment1_key.pem"
REMOTE_HOST=$(aws ec2 describe-instances --instance-ids "$EC2_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "$REMOTE_HOST"
chmod 400 Assignment1_key.pem 
chmod 755 app_setup

ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$REMOTE_HOST" << EOF
  sudo apt update
  sudo apt install -y nginx
  sudo useradd -m -d /a01 -s /bin/bash a01
  sudo mkdir -p /a01/web_root
  sudo mkdir -p /a01/app
  sudo chown -R a01:a01 /a01
  sudo chmod -R 755 /a01
  sudo sed -i 's|root /var/www/html;|root /a01/web_root;|' /etc/nginx/sites-available/default
  sudo systemctl reload nginx
EOF


sudo scp -o StrictHostKeyChecking=no -i "$KEY_FILE" -r app_setup/frontend/index.html ubuntu@"$REMOTE_HOST":/a01/web_root

sudo scp -o StrictHostKeyChecking=no -i "$KEY_FILE" -r app_setup/backend ubuntu@"$REMOTE_HOST":/a01/app

ssh -o StrictHostKeyChecking=no -i "$KEY_FILE" ubuntu@"$REMOTE_HOST" << EOF
  sudo apt update
  sudo apt install -y python3-pip
  sudo apt install -y libmysqlclient-dev
  sudo apt install -y libmysqlclient-dev pkg-config
  pip3 install -r /a01/app/backend/requirements.txt
  pip3 install mysqlclient
  sudo apt install -y mysql-server
  sudo mysql -e "CREATE DATABASE backend;"
  sudo mysql -e "CREATE USER 'example'@'localhost' IDENTIFIED BY 'secure';"
  sudo mysql -e "GRANT ALL PRIVILEGES ON backend.* TO 'example'@'localhost';"
  sudo mysql -e "FLUSH PRIVILEGES;"

  sudo sed -i '/server_name _;/a \
    location /json {\
        proxy_pass http://localhost:5000;\
    }' /etc/nginx/sites-available/default

  sudo systemctl daemon-reload
  sudo systemctl enable backend
  sudo systemctl start backend
EOF

