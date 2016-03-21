#!/bin/bash
# OpenZWave - https://thefrinkiac7.wordpress.com/node-red/build-open-zwave-control-panel-on-a-raspberry-pi/
git clone https://github.com/OpenZWave/open-zwave open-zwave-read-only
cd open-zwave-read-only
make
make install
cd ..
#MinOZW
# Build Node-OpenZWave
git clone https://github.com/ekarak/node-openzwave-shared node-openzwave-shared
git clone https://github.com/ekarak/node-red-contrib-openzwave node-red-contrib-openzwave
cd node-openzwave-shared

cd ..
# Control panel - https://thefrinkiac7.wordpress.com/node-red/build-open-zwave-control-panel-on-a-raspberry-pi/
wget ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.19.tar.gz
tar zxvf libmicrohttpd-0.9.19.tar.gz
mv libmicrohttpd-0.9.19 libmicrohttpd
cd libmicrohttpd
./configure
make
sudo make install
sudo apt-get install -y libgnutls28-dev libgnutlsxx28 libgnutls-dev
git clone https://github.com/OpenZwave/open-zwave-control-panel/open-zwave-control-panel
cd openzwave-control-panel
# Manually do these steps:
# for Linux uncomment out next two lines from the Makefile
#LIBZWAVE := $(wildcard $(OPENZWAVE)/cpp/lib/linux/*.a)
#LIBUSB := -ludev
#LIBS := $(LIBZWAVE) $(GNUTLS) $(LIBMICROHTTPD) -pthread $(LIBUSB)
#Also edit the location of OpenZwave?
#
#OPENZWAVE := ../open-zwave-read-only
#You may need to make a directory within the openzwave directory of “../cpp/lib/linux/” and copy all the libopenzwave.* files from the parent DIR into this one. Then:
#
#make
#Next, you’ll need to, link the OZWCP to the config dir of open zwave, most likely from ../open-zwave-control-panel/ dir, so do a:
#
# ln -s ../openzwave-1.4.1/config config
#Now, you’ll need to To run OZWCP:
#
#./ozwcp -d -p 12345
#Now point a browser to http://yourserver:12345/ and you should be able to see/edit your Zwave network.