#!/bin/bash
sudo apt-get install mongodb
sudo apt-get install npm
wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb
node -v
sudo npm install -g http
sudo npm install -g express
sudo npm install -g json-proxy
git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor.git
meteor/meteor --version
curl http://textbelt.com/text -d number=206 -d "message=Meteor setup complete, access at IP: ${ip}"
