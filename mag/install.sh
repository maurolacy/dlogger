#!/bin/bash

sudo apt-get update 
#sudo apt-get -y upgrade 
sudo apt-get install -y i2c-tools python-smbus install python3 python3-mysql.connector # git

sudo sh -c 'echo "i2c_dev\ni2c_bcm2708" >>/etc/modules'

WD=`pwd` 

# Get the libraries. Among the libraries we will be needing is "quick2wire" and "i2clibraries" for python from Think-Bowl. Make a folder for your project, lets say the folder's name is "project", type in the following commands. (everything after "#" symbol is just comments for you to read)
git clone https://github.com/quick2wire/quick2wire-python-api.git

export QUICK2WIRE_API_HOME=`pwd`/quick2wire-python-api
export PYTHONPATH=$PYTHONPATH:$QUICK2WIRE_API_HOME

cd $QUICK2WIRE_API_HOME

git clone https://bitbucket.org/thinkbowl/i2clibraries.git #getting library files containing functions for i2c devices such as HMC5883L, ITG-3205, ADXL345 and LCD
cd ..
ln -s quick2wire-python-api/i2clibraries

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
