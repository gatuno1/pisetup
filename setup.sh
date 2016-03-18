#!/bin/bash
# Whiptail examples - http://xmodulo.com/create-dialog-boxes-interactive-shell-script.html
oldhostname=$(hostname)
newhostname=$(whiptail --title "Hostname" --inputbox "Change hostname?" 10 60 $oldhostname 3>&1 1>&2 2>&3)
phonenum=$(whiptail --title "Phone Number" --inputbox "Enter phonenumber to text when script is done" 10 60 3>&1 1>&2 2>&3)
# pass=$(whiptail --title "Pi Password" --inputbox "Enter the Pi user password" 10 60 raspberry 3>&1 1>&2 2>&3)
timezone=$(whiptail --title "Timezone" --radiolist \
"What is your timezone?" 15 60 4 \
"US/Pacific" "" ON \
"Europe/Berlin" "" OFF 3>&1 1>&2 2>&3)
newuser=$(whiptail --title "Username" --inputbox "Enter new username if you want one" 10 60 3>&1 1>&2 2>&3)
if [ -n "$newuser" ]
then
   newuserpass=$(whiptail --title "${newuser} Password" --inputbox "Enter ${newuser}'s password" 10 60 3>&1 1>&2 2>&3)
   newuserpasscrypt=$(openssl passwd -crypt ${newuserpass})
   sudo useradd -b /home -c ${newuser} -g users -m -p ${newuserpasscrypt} -s /bin/bash ${newuser}
fi
# Optional packages to install
pkglist=$(whiptail --title "Install Checklist" --checklist \
"Choose packages to install" 15 60 8 \
"xrdp" "XRDP & Conky" ON \
"emacs" "Emacs" ON \
"dnsmasq" "DNSMasq" ON \
"sendmail" "Sendmail & Mailutils" ON \
"shellinabox" "Shell In A Box" ON \
"rpi" "RPi Monitor" ON \
"chrome" "Chromium" ON \
"mongodb" "MongoDB" ON \
3>&1 1>&2 2>&3)
# Configuration options
configopts=$(whiptail --title "Configure Options" --checklist \
"Do you want these configured" 15 60 8 \
"nodered" "Node Red nodes" ON \
"wpa" "WiFi credentials file" ON \
"autostart" "X11 autostart file" ON \
"rpi" "RPi Monitor" ON \
3>&1 1>&2 2>&3)
#### start the setup process ####
STARTTIME=$(date +%s)
echo "alias ll='ls -l'" >> ~/.bashrc
# Update timezone
sudo rm /etc/localtime
#sudo ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
sudo ln -s /usr/share/zoneinfo/${timezone} /etc/localtime
# create users
# update package list info
echo "-- Updating package list"
sudo apt-get -y update
# update and upgrade
echo "-- Upgrading all packages"
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
# remove unneeded packages, ideas from https://blog.samat.org/2015/02/05/slimming-an-existing-raspbian-install/
echo "-- Removing unneeded packages"
sudo apt-get remove -y wolfram-engine
sudo apt-get remove -y sonic-pi
## packages always added
echo "-- Installing npm, perl libs & nmap"
sudo apt-get -y install npm
# perl libs
sudo apt-get -y install dpkg-dev librrds-perl libhttp-daemon-perl libjson-perl libipc-sharelite-perl libfile-which-perl
sudo apt-get -y install  libxml-simple-perl libwww-mechanize-shell-perl libdatetime-event-ical-perl
# nmap network discovery
sudo apt-get -y nmap aptitude
## package selected from install list
for pkg in $pkglist
do
  case $pkg in
    \"xrdp\")
      echo "-- Installing XRDP"
      sudo apt-get install -y xrdp
      sudo apt-get install -y conky
    ;;
    \"emacs\")
      echo "-- Installing emacs"
      sudo apt-get install -y emacs
    ;;
    \"dnsmasq\")
      echo "-- Installing dnsmasq"
      # DNS & DHCP
      sudo apt-get -y install dnsmasq
    ;;
    \"sendmail\")
      echo "-- Installing sendmail"
      # Sendmail
      sudo apt-get -y install sendemail libio-socket-ssl-perl libnet-ssleay-perl
      sudo apt-get -y mail mbox mailutils
    ;;
    \"shellinabox\")
      echo "-- Installing shellinabox"
      # shell in a box /Webgui
      sudo apt-get -y install shellinabox
    ;;
    \"rpi\")
      echo "-- Installing RPi Monitor"
      # RPi Monitor
      sudo apt-get -y install apt-transport-https ca-certificates
      sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2C0D3C0F
      sudo wget http://goo.gl/rsel0F -O /etc/apt/sources.list.d/rpimonitor.list
      sudo apt-get update
      sudo apt-get -y install rpimonitor
      sudo apt-get -y install aptitude
      sudo apt-get upgrade
      sudo /usr/share/rpimonitor/scripts/updatePackagesStatus.pl
      # RPi Monitor
      #wget https://github.com/XavierBerger/RPi-Monitor-deb/raw/master/packages/rpimonitor_2.10.1-1_all.deb
      #wget https://github.com/XavierBerger/RPi-Monitor-deb/blob/master/packages/rpimonitor_2.10-1_all.deb
    ;;
    \"chrome\")
      echo "-- Installing Chromium"
      # chrome
      wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser-l10n_45.0.2454.85-0ubuntu0.15.04.1.1181_all.deb
      wget https://dl.dropboxusercontent.com/u/87113035/chromium-browser_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
      wget https://dl.dropboxusercontent.com/u/87113035/chromium-codecs-ffmpeg-extra_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
      sudo dpkg -i chromium-codecs-ffmpeg-extra_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
      sudo dpkg -i chromium-browser-l10n_45.0.2454.85-0ubuntu0.15.04.1.1181_all.deb chromium-browser_45.0.2454.85-0ubuntu0.15.04.1.1181_armhf.deb
    ;;
    \"mongodb\")
      echo "-- Installing MongoDB"
      sudo apt-get -y install mongodb
    ;;
    \"zwave\")
      echo "-- Installing ZWave"
      sudo apt-get -y install libudev-dev
      wget http://old.openzwave.com/downloads/openzwave-1.4.1.tar.gz
      tar zxvf openzwave-*.gz
      cd openzwave-*
      make && sudo make install
      export LD_LIBRARY_PATH=/usr/local/lib
      //sudo sed -i '$a LD_LIBRARY_PATH=/usr/local/lib' /etc/environment
      sudo echo 'LD_LIBRARY_PATH=/usr/local/lib' >> /etc/environment
      npm install node-gyp
      npm install openzwave-shared
      wget https://raw.githubusercontent.com/OpenZWave/node-openzwave-shared/master/test2.js
    ;;
    *)
    ;;
  esac
done
## config options
echo "-- Configuration options"
for pkg in $configopts
do
  case $pkg in
    \"nodered\")
    mkdir .node-red
    cd node-red
    npm install node-gyp node-red-node-mongodb request thethingbox-node-timestamp
    ;;
    \"wpa\")
      sudo cp wpa_supplicant.conf /etc/wpa_supplicant
    ;;
    \"autostart\")
      sudo cp 80autostart /etc/X11/Xsession.d
    ;;
    \"rpi\")
    ;;
    *)
    ;;
  esac
done
# Startup services
sudo systemctl enable nodered.service
# change hostname
echo "-- Setting hostname"
if [ "$oldhostname" != "$newhostname" ]
then
    sudo sed -i "s/$oldhostname/$newhostname/g" /etc/hostname
    sudo sed -i "s/$oldhostname/$newhostname/g" /etc/hosts
fi
ENDTIME=$(date +%s)
ELAPSED=$(($ENDTIME - $STARTTIME))
NICETIME=$(printf '%dh:%dm:%ds\n' $(($ELAPSED/3600)) $(($ELAPSED%3600/60)) $(($ELAPSED%60)))
# Send a text message
ip=`ifconfig|xargs|awk '{print $7}'|sed -e 's/[a-z]*:/''/'`
curl http://textbelt.com/text -d number=${phonenum} -d "message=Setup complete, ${NICETIME}, rebooting, access at IP: ${ip}"
sudo reboot
