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
import sys
import os

pin = 23 # GPIO BCM
delay = .0001 # [seconds]
sampleTime = 30. # [seconds]

def setup():
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.IN)

def setup_db(db, user, password):
    import MySQLdb
    host = "localhost"
    port = 3306

#    print "DB:", db, "USER:", user, "PASS:", password

    # Connect to the Database
    db=MySQLdb.connect(host=host, user=user, passwd=password, db=db, port=port)

    # Make the database cursor
    return db.cursor()

def usage():
    print "Usage: %s [-m mode]\n-m: output mode\n  stdout: standard output(default)\n  mysql : mysql db(data logger)\n  table : tabular(standard output)" % sys.argv[1]
    sys.exit(1)

if __name__ == "__main__":
    mode='stdout' # default
    if len(sys.argv) > 1:
        if sys.argv[1] in ('-h', '--help'):
            usage()
        if sys.argv[1] == "-m":
            if len(sys.argv) != 3:
                usage()
            mode = sys.argv[2]
            if mode not in ('stdout', 'mysql', 'table'):
                usage()
        else:
            usage()

    if mode == 'mysql':
        DB = os.getenv("DB")
        USER=os.getenv("US")
        PASS=os.getenv("PASS")
        db_cursor = setup_db(DB, USER, PASS)

    setup()
    level = oldLevel = True

    while True:
        timer = 0.
        lowTime = 0.
        cycleStart = time.time()
        start = cycleStart
        while timer < sampleTime:
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
        ratio = lowTime / sampleTime
        if ratio > 1.:
            ratio = 1.
        pcs = 3.5314667 * (49896.9 * ratio + 5154.98 * ratio**2 + 814480. * ratio**3)
        if mode == 'stdout':
            print "Low pulse occupancy: %.2f%%. Concentration: %d pcs/L" % (ratio*100, pcs)
        elif mode == 'mysql':
            print "%d %.2f %d" % (time.time(), ratio*100., pcs)
            assert(db_cursor)
            db_cursor.execute('INSERT INTO `dust` (`low_percent`, `pcs`, `duration`, `interval`) VALUES (%f, %d, %d, %d);' % (ratio*100., pcs, sampleTime, 0))
        elif mode == 'table':
            print "%d %.2f %d" % (time.time(), ratio*100, pcs)
    GPIO.cleanup()
