#!/bin/bash

sudo apt-get -y install python-smbus python-mysqldb

sudo sh -c 'echo "i2c_dev\ni2c_bcm2708" >>/etc/modules'

WD=`pwd` 

# Instalar apache2
#cd ../httpd
#sudo ./install_publish.sh

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/getpressure
cd -

sudo update-rc.d getpressure defaults
sudo update-rc.d getpressure enable 2 3 4 5

sudo service getpressure restart
