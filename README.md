# Raspberry Pi Setup Files

These are some setup files for a new Raspberry Pi. There's a 1 minute demo of the script [here](https://youtu.be/llwiVLaB8lU).

### setup.sh

Here's what the main setup.sh script installs

* New prompts to select packages to install
* WiFi SSID's/passwords
* 80autostart - autostart file
* xrdp
* conky
* emacs
* Chrome browser
* npm to support NodeRed
* mongodb to support NodeRed
* Calculate install time and include with text message
* Add prompts to select install of dependent files
* Install Node Red nodes

### url's

* RPi Monitor - http://<hostname>:8888
* Node Red - http://<hostname>:1880
* ShellInABox - http://<hostname>:4200
* OpenHAB - http://<localhost>:8080/openhab.app?sitemap=yourname (not yet working)

##### ToDo

* RPi Monitor config (top3, shellinabox)
    cron.d, data.conf
* ZWave install - USB Stick, nodered
* Option to install Touch screen
   https://www.element14.com/community/docs/DOC-77915/l/i-can-see-clearly-now-with-the-4d-systems-24-touch-screen-for-the-raspberry-pi
* Run RPi update process
   sudo apt-get update && sudo /usr/share/rpimonitor/scripts/updatePackagesStatus.pl
* Pi password not set
* Calculate disk space used
* If user chooses Cancel on any prompt, abort setup script

##### Fixed bugs

* Error - Unable to resolve host raspberrypi
* can't overwrite /etc/localtime, delete first

#### Dependencies

These files must be in the setup.sh home directory to function correctly:

* wpa_supplicant.conf
* 80autostart
* .conkyrc

#### Notes

* Choose apps to start on boot: RPi Monitor, Node Red, MongoDB
  * Node Red
     sudo systemctl enable nodered.service
  * MongoDB
    http://stackoverflow.com/questions/17901627/setting-up-mongodb-raspberry-pi
    http://c-mobberley.com/wordpress/2013/10/14/raspberry-pi-mongodb-installation-the-working-guide/
    sudo cp debian/init.d /etc/init.d/mongod
    sudo cp debian/mongodb.conf /etc/
    sudo ln -s /opt/mongo/bin/mongod /usr/bin/mongod
    sudo chmod u+x /etc/init.d/mongod
    sudo update-rc.d mongod defaults
    sudo /etc/init.d/mongod start
