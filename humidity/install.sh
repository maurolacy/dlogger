#!/bin/bash

WD=`pwd` 

# Configurar script de arranque
cd /etc/init.d
sudo ln -s $WD/gethumidity
cd -

sudo update-rc.d gethumidity defaults
sudo update-rc.d gethumidity enable 2 3 4 5

sudo service gethumidity restart
