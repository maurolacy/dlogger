#!/bin/bash

WD=`pwd` 

# Instalar apache2
cd ../httpd
sudo ./install_publish.sh

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/getpart
cd -

# Agregar la línea al archivo /etc/rc.local
sudo sed -i 's/^exit 0/service getpart start\n\nexit 0' /etc/rc.local

# Reiniciar
sudo reboot
