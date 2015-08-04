#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

"""
 Interface to Bosch Model bpm180 Pressure and Temperature Sensor
 06/2015
 
"""
import time
import sys
import os

import smbus
import bmp180

bus = 1
cache = 1 # [seconds]
oversampling_mode = bmp180.OS_MODE_8
interval = 300 # [seconds]

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
    print "Usage: %s [-m mode]\n-m: output mode\n  stdout: standard output(default)\n  mysql : mysql db(data logger)\n  table : tabular(standard output)" % sys.argv[0]
    sys.exit(1)

if __name__ == '__main__':
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

    bus = smbus.SMBus(bus)
    sensor = bmp180.Bmp180(bus)
    sensor.cache_lifetime = cache
    sensor.os_mode = oversampling_mode
#    print 'Oversampling mode is %d' % mode

    if mode == 'mysql':
        DB = os.getenv("DB")
        USER=os.getenv("US")
        PASS=os.getenv("PASS")
        db_cursor = setup_db(DB, USER, PASS)

    level = oldLevel = True

    while True:
        (P, T) = sensor.pressure_and_temperature
        if mode == 'stdout':
            print "Temperature: %.1f °C, Pressure: %.2f hPa" % (T, P)
        elif mode == 'mysql':
            print "%d %.1f %.2f" % (time.time(), T, P)
            assert(db_cursor)
            db_cursor.execute('INSERT INTO `pressure` (`temp`, `pressure`, `duration`, `interval`) VALUES (%f, %f, %d, %d);' % (T, P, 0, interval))
        elif mode == 'table':
            print "%d %.1f %.2f" % (time.time(), T, P)
        time.sleep(interval)
