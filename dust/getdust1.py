#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

"""
 Interface to Shinyei Model PPD42NS Particle Sensor
 Raspberry PI Python version by Mauro Lacy
 06/2015
 
 http://www.seeedstudio.com/depot/grove-dust-sensor-p-1050.html
 http://www.sca-shinyei.com/pdf/PPD42NS.pdf
 
 JST Pin 1 (Black Wire)  => PI GND
 JST Pin 3 (Red wire)    => PI 5VDC
 JST Pin 4 (Yellow wire) => PI BCM GPIO #23

"""
import RPi.GPIO as GPIO
import time

pin = 23 # GPIO BCM
delay = .0001 # [seconds]
interval = 30. # [seconds]

def setup():
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.IN)

if __name__ == "__main__":
    setup()
    level = oldLevel = True

    while True:
        timer = 0.
        lowTime = 0.
        cycleStart = time.time()
        start = 0.
        while timer < interval:
            level = GPIO.input(pin)
            t = time.time()
            if (level != oldLevel):
                if level:
#                   print ("Low level duration: %f ms" % (t * 1000))
                    lowTime += t - start
                else:
                    start = t
            oldLevel = level
            timer = t - cycleStart
            time.sleep(delay)
#           print 'timer:', timer
        ratio = lowTime / interval
        pcs = 3.5314667 * (49896.9 * ratio + 5154.98 * ratio**2 + 814480. * ratio**3)
        print "Low pulse occupancy: %f%%. Concentration: %d pcs/L" % (ratio*100, pcs)
    GPIO.cleanup()
