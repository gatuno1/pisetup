#!/bin/bash
# Whiptail examples - http://xmodulo.com/create-dialog-boxes-interactive-shell-script.html
oldhostname=$(hostname)
newhostname=$(whiptail --title "Hostname" --inputbox "Change hostname?" 10 60 $oldhostname 3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
phonenum=$(whiptail --title "Phone Number" --inputbox "Enter phonenumber to text when script is done" 10 60 3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
toemail=$(whiptail --title "gmail" --inputbox "Enter gmail (w/o @gmail.com) address to notify when script is done" 10 60 3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
if [ -n "$toemail" ]
then
   emailpass=$(whiptail --title "${toemail} Password" --passwordbox "Enter ${toemail}'s password" 10 60 3>&1 1>&2 2>&3)
fi
# pass=$(whiptail --title "Pi Password" --inputbox "Enter the Pi user password" 10 60 raspberry 3>&1 1>&2 2>&3)
timezone=$(whiptail --title "Timezone" --radiolist \
"What is your timezone?" 15 60 4 \
"US/Pacific" "" ON \
"Europe/Berlin" "" OFF 3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
newuser=$(whiptail --title "Username" --inputbox "Enter new username if you want one" 10 60 3>&1 1>&2 2>&3)
if [ -n "$newuser" ]
then
   newuserpass=$(whiptail --title "${newuser} Password" --passwordbox "Enter ${newuser}'s password" 10 60 3>&1 1>&2 2>&3)
   newuserpasscrypt=$(openssl passwd -crypt ${newuserpass})
   sudo useradd -b /home -c ${newuser} -g users -m -p ${newuserpasscrypt} -s /bin/bash ${newuser}
fi
# Optional packages to install
pkglist=$(whiptail --title "Install Checklist" --checklist \
"Choose packages to install" 20 60 15 \
"xrdp" "XRDP & Conky" OFF \
"emacs" "Emacs" ON \
"dnsmasq" "DNSMasq" OFF \
"sendmail" "Sendmail & Mailutils" ON \
"shellinabox" "Shell In A Box" ON \
"rpi" "RPi Monitor" ON \
"chrome" "Chromium" OFF \
"node" "Upgrade Node.js to 0.12.x" ON \
"mongodb" "MongoDB" ON \
"apache" "Apache" ON \
"freeboard" "Freeboard Dashboard" ON \
"mosca" "MQTT (Mosca)" OFF \
"mosquitto" "Mosquitto" OFF \
"zwave" "ZWave" OFF \
"openhab" "OpenHAB" OFF \
"touchscreen" "Touch Screen" OFF \
3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
# Configuration options
configopts=$(whiptail --title "Configure Options" --checklist \
"Do you want these configured" 15 60 8 \
"nodered" "Node Red nodes" ON \
"wpa" "WiFi credentials file" ON \
"autostart" "X11 autostart file" OFF \
"rpi" "RPi Monitor" ON \
"mosca" "Mosca" OFF \
"openhab" "OpenHAB" OFF \
"touchscreen" "Enable Touch Screen" OFF \
3>&1 1>&2 2>&3)
export exitstatus=$?
if [ $exitstatus != 0 ]; then
  exit $exitstatus
fi
#for pkg in $pkglist
#do
#  case $pkg in
#    \"mosca\")
#      mqttuser=$(whiptail --title "MQTT User" --inputbox "Enter new Mosca MQTT user" 10 60 3>&1 1>&2 2>&3)
#      if [ -n "$mqttuser" ]
#      then
#         mqttpass=$(whiptail --title "${mqttuser} Password" --passwordbox "Enter ${mqttuser}'s password" 10 60 3>&1 1>&2 2>&3)
#      fi
#      ;;
#  esac
#done
#### start the setup process ####
STARTTIME=$(date +%s)
sudo echo "alias ll='ls -l'" >> ~/.bashrc
# Update timezone
sudo rm /etc/localtime
#sudo ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
sudo ln -s /usr/share/zoneinfo/${timezone} /etc/localtime
# create users
# update package list info
echo "-- Listing /etc/apt/sources.list.d because of past issues"
ls -l /etc/apt/sources.list.d
echo "-- Updating package list"
# sudo apt-get -y install apt-transport-https
sudo apt-get -y update
echo apt-get update status: $?
# update and upgrade
echo "-- Upgrading all packages"
sudo apt-get -y upgrade
echo apt-get upgrade status: $?
sudo apt-get -y dist-upgrade
echo apt-get dist-upgrade status: $?
# remove unneeded packages, ideas from https://blog.samat.org/2015/02/05/slimming-an-existing-raspbian-install/
echo "-- Removing unneeded packages"
sudo apt-get remove -y wolfram-engine
sudo apt-get remove -y sonic-pi
## packages always added
echo "-- Installing perl libs & nmap"
# perl libs
sudo apt-get -y install dpkg-dev librrds-perl libhttp-daemon-perl libjson-perl libipc-sharelite-perl libfile-which-perl
sudo apt-get -y install libxml-simple-perl libwww-mechanize-shell-perl libdatetime-event-ical-perl
# nmap network discovery
sudo apt-get -y nmap aptitude
## package selected from install list
for pkg in $pkglist
do
  case $pkg in
    \"node\")
      echo "-- Removing old Node.js, Mosca needs newer version"
      sudo apt-get -y remove nodejs-legacy nodejs-dev nodejs
      #sudo apt-get -y remove npm
      echo "-- Installing latest Node.js for Mosca"
      # these steps got me v4.4.0 in March 2016
      #curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
      #sudo apt-get install -y build-essential python-dev python-rpi.gpio nodejs
      # Need 0.12 for Mosca - this does 0.12.6
      wget http://node-arm.herokuapp.com/node_archive_armhf.deb
      sudo dpkg -i node_archive_armhf.deb
      sudo ln -s /usr/local/bin/node /usr/bin/node
      sudo apt-get install -y npm
      # Install startup files
      sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/nodered.service -O /lib/systemd/system/nodered.service
      sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-start -O /usr/bin/node-red-start
      sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-stop -O /usr/bin/node-red-stop
      sudo chmod +x /usr/bin/node-red-st*
      sudo systemctl daemon-reload
      sudo systemctl start nodered
      sudo systemctl enable nodered.service
      # For older Pi's (installed 4.2.1 in March 2016)
      # wget http://node-arm.herokuapp.com/node_latest_armhf.deb
      # sudo dpkg -i node_latest_armhf.deb
      # sudo apt-get install -y build-essential python-dev npm
    ;;
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
      # Remove the RPi Monitor list because it causes cache problems updating other packages
      sudo rm /etc/apt/sources.list.d/rpimonitor.list
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
      rm chromium*
    ;;
    \"mongodb\")
      echo "-- Installing MongoDB"
      # Mongo test commands: https://docs.mongodb.org/manual/reference/mongo-shell/
      # Logfile: /var/log/mongodb/mongod.log
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
      #echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
      #sudo apt-get update
      #sudo apt-get install -y mongodb-org
      #sudo service mongod start
      sudo apt-get -y install mongodb
      # sudo systemctl status mongodb.service
    ;;
    \"apache\")
      echo "-- Installing Apache"
      sudo apt-get -y install apache2 php5 libapache2-mod-php5
      sudo service apache2 restart
    ;;
    \"freeboard\")
      echo "-- Installing Freeboard"
      git clone https://github.com/Freeboard/freeboard.git
      sudo ln -s freeboard /var/www/freeboard
      # /etc/apache2/sites-available/000-default.conf
      # <VirtualHost *:81>
      #   DocumentRoot /var/www/freeboard
      # </VirtualHost>
    ;;
    \"mosca\")
      echo "-- Installing MQTT Mosca"
      # Mongo test commands: https://docs.mongodb.org/manual/reference/mongo-shell/
      # sudo npm install -y node-gyp
      sudo apt-get install -y libkrb5-dev
      sudo apt-get install -y libzmq3 libzmq3-dev python
      # local install
      # npm install mosca bunyan -y --unsafe-perm
      # global install
      sudo npm install mosca bunyan -y -g --unsafe-perm
      # global install locatin: /usr/local/bin/mosca
      # local install location: node_modules/mosca/bin/mosca
      # sudo npm install -y -g node-gyp
      # sudo npm install -y -g mosca bunyan
    ;;
    \"mosquitto\")
      echo "-- Installing Mosquitto"
      sudo wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
      sudo apt-key add mosquitto-repo.gpg.key
      cd /etc/apt/sources.list.d/
      sudo wget http://repo.mosquitto.org/debian/mosquitto-jessie.list
      sudo apt-get update
      # sudo apt-get -y install mosquitto
      sudo apt-get -y install mosquitto mosquitto-clients python-mosquitto
      sudo git https://gist.github.com/basuke/7777918 /etc/init.d.mosquitto
    ;;
    \"zwave\")
      echo "-- Installing ZWave"
      sudo apt-get -y install libudev-dev
      wget http://old.openzwave.com/downloads/openzwave-1.4.1.tar.gz
      tar zxvf openzwave-*.gz
      cd openzwave-*
      make && sudo make install
      export LD_LIBRARY_PATH=/usr/local/lib
      echo 'LD_LIBRARY_PATH=/usr/local/lib' | sudo tee --append /etc/environment
      npm install -y node-gyp
      npm install -y openzwave-shared
      wget https://raw.githubusercontent.com/OpenZWave/node-openzwave-shared/master/test2.js
    ;;
    \"openhab\")  # https://github.com/openhab/openhab/wiki/Linux---OS-X
      echo "-- Installing OpenHAB"
      wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' |sudo apt-key add -
      echo "deb http://dl.bintray.com/openhab/apt-repo stable main" | sudo tee /etc/apt/sources.list.d/openhab.list
      sudo apt-get update
      sudo apt-get install openhab-runtime
      # sudo update-rc.d openhab defaults
      # sudo chown -hR openhab:openhab /etc/openhab
      # sudo chown -hR openhab:openhab /usr/share/openhab
    ;;
    \"touchscreen\")
      echo "-- Installing Touch Screen"
      wget http://www.4dsystems.com.au/downloads/4DPi/4DPi-24-HAT/4DPi-24-HAT_kernel_R_1_0.tar.gz
      sudo tar -xzvf 4DPi-24-HAT_kernel_R_1_0.tar.gz -C /
      rm 4DPi-24-HAT_kernel_R_1_0.tar.gz
    ;;
    *)
    ;;
  esac
done
echo "-- Installing npm"
sudo apt-get -y install npm
## config options
echo "-- Configuration options"
for pkg in $configopts
do
  case $pkg in
    \"nodered\")
      echo "-- Add nodered packages"
      mkdir .node-red
      cd .node-red
      npm install -y node-gyp node-red-node-mongodb request thethingbox-node-timestamp node-red-contrib-deduplicate node-red-contrib-textbelt
      # Startup services
      sudo systemctl enable nodered.service
    ;;
    \"wpa\")
      sudo cp wpa_supplicant.conf /etc/wpa_supplicant
    ;;
    \"autostart\")
      sudo cp 80autostart /etc/X11/Xsession.d
    ;;
    \"rpi\")
      sudo cp /usr/share/rpimonitor/web/addons/top3/top3.cron /etc/cron.d/top3
      sudo echo "web.addons.1.name=Shellinabox" >>/etc/rpimonitor/data.conf
      sudo echo "web.addons.1.addons=shellinabox" >>/etc/rpimonitor/data.conf
      sudo echo "web.addons.2.name=Top3" >>/etc/rpimonitor/data.conf
      sudo echo "web.addons.2.addons=top3" >> /etc/rpimonitor/data.conf
      sudo sed -i "s/$nbtop=3/$nbtop=10/" /usr/share/rpimonitor/web/addons/top3/top3
      sudo service rpimonitor restart
    ;;
    \"mosca\")
      echo "-- Configure Mosca"
      chmod +x mosca.sh
      mosca addu^Cr spadafy spadafy --credentials ./moscacreds.json
      sudo cp mosca.sh /etc/init.d/mosca
      sudo chown root:root /etc/init.d/mosca
      sudo update-rc.d mosca defaults
      sudo service mosca start
      # Log: /var/log/mosca.log
    ;;
    \"openhab\")
      sudo systemctl daemon-reload
      sudo systemctl enable openhab
      # following needed for ZWave stick
      sudo usermod -a -G dialout openhab
      sudo apt-get install openhab-addon-persistence-rrd4j
      sudo apt-get install openhab-addon-binding-zwave
      sudo apt-get install openhab-addon-io-myopenhab
      sudo apt-get install openhab-addon-persistence-logging
      sudo apt-get install openhab-addon-persistence-mongodb
      sudo apt-get install openhab-addon-action-mail
      sudo apt-get install openhab-addon-action-nma
      sudo apt-get install openhab-addon-action-prowl
      sudo apt-get install openhab-addon-action-pushover
      sudo apt-get install openhab-addon-binding-plex
      # /etc/default/openhab  &  /etc/openhab/configurations/openhab_default.cfg
      sudo -u openhab cp /etc/openhab/configurations/openhab_default.cfg /etc/openhab/configurations/openhab.cfg
      # edit the openhab.cfg file
      # zwave:port, mongodb parms

      # sitemaps - https://github.com/openhab/openhab/wiki/Explanation-of-Sitemaps
      sudo -u openhab touch /etc/openhab/configurations/sitemaps/default.sitemap
      wget https://raw.githubusercontent.com/openhab/openhab-distro/master/features/openhab-demo-resources/src/main/resources/sitemaps/demo.sitemap
      sudo -u openhab cp demo.sitemap /etc/openhab/configurations/sitemaps/default.sitemap
      sudo systemctl start openhab
    ;;
    \"osticket\")
      # https://github.com/osTicket/osTicket
      # http://localhost/osticket
      sudo apt-get install -y mysql-server python-mysqldb php5-mysql php5-imap php5-apcu php5-gd
      git clone https://github.com/osTicket/osTicket-1.8
      cd osTicket-1.8
      sudo php manage.php deploy --setup /var/www/html/osticket/
    ;;
    \"touchscreen\")
      # https://learn.adafruit.com/adafruit-2-2-pitft-hat-320-240-primary-display-for-raspberry-pi/extras
      sudo mv /usr/share/X11/xorg.conf.d/99-fbturbo.conf ~
      sudo echo 'Section "Device"' | sudo tee --append /usr/share/X11/xorg.conf.d/99-pitft.conf
      sudo echo '  Identifier "Adafruit PiTFT"' | sudo tee --append /usr/share/X11/xorg.conf.d/99-pitft.conf
      sudo echo '  Driver "fbdev"' | sudo tee --append /usr/share/X11/xorg.conf.d/99-pitft.conf
      sudo echo '  Option "fbdev" "/dev/fb1"' | sudo tee --append /usr/share/X11/xorg.conf.d/99-pitft.conf
      sudo echo 'EndSection' | sudo tee --append /usr/share/X11/xorg.conf.d/99-pitft.conf
    ;;
    *)
    ;;
  esac
done
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
if [ -n "$phonenum" ]
then
  curl http://textbelt.com/text -d number=${phonenum} -d "message=Setup complete, ${NICETIME}, rebooting ${newhostname}, access at IP: ${ip}"
fi
if [ -n "$toemail" ]
then
  sendemail -f ${toemail}@gmail.com -t ${toemail}@gmail.com -u "${newhostname} Pi Setup Complete" -m "message=Setup complete, ${NICETIME}, rebooting ${newhostname}, access at IP: ${ip}" -s smtp.gmail.com:587 -o tls=yes -xu ${toemail} -xp ${emailpass}
fi
echo "-- I'm done, rebooting"
sudo reboot
