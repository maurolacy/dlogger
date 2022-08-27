#!/usr/bin/python3

from i2clibraries import i2c_adxl345
from time import *
 
adxl345 = i2c_adxl345.i2c_adxl345(1)
 
#print(adxl345)
axes = adxl345.getAxes()

print(axes[0], axes[1], axes[2])
