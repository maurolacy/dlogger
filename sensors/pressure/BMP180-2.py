#!/usr/bin/python
#coding: utf-8

# Import libraries needed for program
import RPi.GPIO as GPIO, Adafruit_BMP.BMP085 as BMP085, os, datetime, time, math
from Adafruit_I2C import Adafruit_I2C

# This prevents warnings from crashing the program due to GPIO issues
GPIO.setwarnings(False)
DEBUG = 1
GPIO.setmode(GPIO.BCM)

# Initialize the BMP085 sensor in high resolution mode
sensor = BMP085.BMP085()

# Main Loop
while True:
#   now = datetime.datetime.now()
#   timeStamp = now.strftime("%m%d%Y_%H%M%S")
   temp = sensor.read_temperature()
   altitude = sensor.read_altitude()
   pressure = sensor.read_pressure()
   seaPressure = sensor.read_sealevel_pressure() 
   print "Temp = %f°C, Alt = %fm, Pres = %fkPa, Sea Level Pres = %fkPa" % (temp, altitude, pressure, seaPressure)

   time.sleep(1)
