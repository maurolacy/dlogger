#!/bin/bash

WD=`pwd` 

# Instalar python 2.7
sudo apt-get update
sudo apt-get install screen python2.7

# Instalar apache2
#cd ../httpd
#sudo ./install_publish.sh

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/getdust
cd -

# Agregar la línea al archivo /etc/rc.local
grep -v "getdust" /etc/rc.local | sudo bash -c "sed 's/^exit 0/service getdust start\nexit 0/' >/etc/rc.local"

# Reiniciar
sudo reboot
