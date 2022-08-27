#!/bin/bash

sudo apt-get update 
sudo apt install -y git i2c-tools python-smbus python3 python-pip python-virtualenv python3-setuptools python3-mysql.connector

#sudo sh -c 'echo "i2c_dev\ni2c_bcm2708" >>/etc/modules'

WD=`pwd` 

git clone https://github.com/quick2wire/quick2wire-python-api

QUICK2WIRE_API_HOME=`pwd`/quick2wire-python-api
#export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME
cd $QUICK2WIRE_API_HOME

sudo python3 setup.py install
cd ..
rm -rf $QUICK2WIRE_API_HOME

git clone https://bitbucket.org/thinkbowl/i2clibraries.git

# Instalar apache2
#cd ../httpd
#sudo ./install_publish.sh

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/getmag
cd -

sudo update-rc.d getmag defaults
sudo update-rc.d getmag enable 2 3 4 5

sudo service getmag restart
