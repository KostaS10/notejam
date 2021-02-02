#!/bin/bash
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
git clone https://github.com/KostaS10/notejam.git
cd notejam/express/notejam/
npm install
node db.js
sudo nohup bin/www > /dev/null 2>&1 &
