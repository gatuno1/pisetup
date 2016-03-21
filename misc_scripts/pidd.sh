#!/bin/bash
export DSK=$1
export IMG=$2
sudo diskutil unmountDisk /dev/disk${DSK}
sudo dd bs=1m if=${IMG} of=/dev/rdisk${DSK}
