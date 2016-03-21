#!/bin/bash
# SD benchmark test from http://www.jeffgeerling.com/blogs/jeff-geerling/raspberry-pi-microsd-card
sudo apt-get install -y hdparm
sudo hdparm -t /dev/mmcblk0
sudo dd if=/dev/zero of=/tmp/output bs=8k count=50k conv=fsync; sudo rm -f /tmp/output
wget http://www.iozone.org/src/current/iozone3_434.tar
cat iozone3_434.tar | tar -x
cd iozone3_434/src/current
make linux-arm
./iozone -e -I -a -s 100M -r 4k -r 512k -r 16M -i 0 -i 1 -i 2 [-f /tmp/test]
