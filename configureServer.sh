#!/bin/bash

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
git clone https://github.com/KostaS10/notejam.git
cd notejam/express/notejam/
npm install
node db.js
sudo npm install -g pm2
pm2 start bin/www
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u nordcloud --hp /home/nordcloud
sudo apt-get install -y nginx
sudo rm -rf /etc/nginx/sites-available/default
sudo cp /home/nordcloud/notejam/express/notejam/default /etc/nginx/sites-available/default
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo reboot
