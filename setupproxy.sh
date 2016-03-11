#!/bin/bash
wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb
node -v
sudo npm install -g http
sudo npm install -g express
sudo npm install -g json-proxy
