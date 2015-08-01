#!/bin/bash

sudo apt-get -y install python-smbus

sudo sh -c 'echo "i2c_dev\ni2c_bcm2708" >>/etc/modules'

WD=`pwd` 

# Instalar apache2
cd ../httpd
sudo ./install_publish.sh

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/getpressure
cd -

# Agregar la línea al archivo /etc/rc.local
sudo sed -i 's/^exit 0/service getpressure start\n\nexit 0/' /etc/rc.local

# Reiniciar
sudo reboot
