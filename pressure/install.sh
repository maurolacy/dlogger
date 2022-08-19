#!/bin/bash

sudo apt update
sudo apt install git build-essential python-dev python-smbus

git clone https://github.com/adafruit/Adafruit_Python_BMP.git

cd Adafruit_Python_BMP
sudo python3 setup.py install

cd ..

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
