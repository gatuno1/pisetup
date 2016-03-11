#!/bin/bash
export oldhostname = `hostname`
echo Current hostname: $oldhostname
echo "Enter new hostname"
read newhostname
if [ -n "$newhostname" ]
then
    sudo sed -i "s/$oldhostname/$newhostname/g" /etc/hostname
    sudo sed -i "s/$oldhostname/$newhostname/g" /etc/hosts
fi
echo "alias ll='ls -l'" >> ~/.bashrc
sudo cp wpa_supplicant.conf /etc/wpa_supplicant
sudo cp 80autostart /etc/X11/Xsession.d
sudo apt-get update -y
sudo apt-get install -y xrdp
sudo apt-get install -y conky
ip=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`
sudo apt-get install -y emacs
wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser-l10n_45.0.2454.85-0ubuntu0.15.04.1.1181_all.deb
wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
wget https://dl.dropboxusercontent.com/u/87113035/chromium-codecs-ffmpeg-extra_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
sudo dpkg -i chromium-codecs-ffmpeg-extra_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
sudo dpkg -i chromium-browser-l10n_45.0.2454.85-0ubuntu0.15.04.1.1181_all.deb chromium-browser_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
curl http://textbelt.com/text -d number=2063844441 -d "message=Setup complete, access at IP: ${ip}"
