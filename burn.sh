#!/bin/bash
echo diskutil list
diskutil list
#echo ABORT IF NOT 2, otherwise return to continue
echo Enter number associated with disk
read disknum
echo diskutil unmountDisk /dev/disk${disknum}
diskutil unmountDisk /dev/disk${disknum}
echo continue?
read a
echo sudo dd bs=1m if=2015-11-21-raspbian-jessie.img of=/dev/rdisk${disknum}
sudo dd bs=1m if=2015-11-21-raspbian-jessie.img of=/dev/rdisk${disknum}
echo sudo diskutil eject /dev/rdisk${disknum}
sudo diskutil eject /dev/rdisk${disknum}
