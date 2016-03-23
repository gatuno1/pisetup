#!/bin/bash
CPU=`cat /proc/cpuinfo | grep Serial | cut -d ':' -f 2 | sed -e "s/ //g"`
HW=`cat /proc/cpuinfo | grep Hardware | cut -d ':' -f 2 | sed -e "s/ //g"`
REV=`cat /proc/cpuinfo | grep Revision | cut -d ':' -f 2 | sed -e "s/ //g"`
case ${REV} in
  a22082)
    echo 'Pi 3, Model B'
    ;;
  a02082)
    echo 'Pi 3, Model B'
    ;;
  a21041)
    echo 'Pi 2, Model B'
    ;;
  a01041)
    echo 'Pi 2, Model B'
    ;;
  900092)
    echo 'Pi Zero'
    ;;
  0012)
    echo 'Pi, Model A+'
    ;;
  0010)
    echo 'Pi, Model B+'
    ;;
  *)
    echo '${REV} (unknown)'
    ;;
esac