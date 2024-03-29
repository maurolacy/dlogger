#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
 Interface to Honeywell Model HMC5883L Digital Compass/Magnetic Field Sensor
 03/2016
 
"""
import time
import sys
import os

from i2c_hmc5883l import i2c_hmc5883l

bus = 1

interval = 300  # [seconds]

def now():
    from datetime import datetime
    return datetime.now()

def setup_db(database, user, password):
    import mysql.connector
    host = "localhost"
    port = 3306

#    print("DB:", database, "USER:", user, "PASS:", password, file=sys.stderr)

    # Connect to the Database
    db = mysql.connector.Connect(host=host, user=user, passwd=password, db=database, port=port)

    return db

def usage():
    print("Usage: %s [-m mode]\n-m: output mode\n  stdout: standard output(default)\n  mysql : mysql db(data logger)\n  table : tabular(standard output)" % sys.argv[0], file=sys.stderr)
    sys.exit(1)

if __name__ == '__main__':
    mode='stdout' # default
    LOG=sys.stderr

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
    if mode == 'stdout':
        interval = 1
    elif mode == 'mysql':
        LOG = os.getenv("BASE") + '/log/%s.log' % os.path.splitext(os.path.basename(sys.argv[0]))[0]
        LOG = open(LOG, 'w')
        print("%s: %s starting..." % (now(), sys.argv[0]), file=LOG)
        LOG.flush()
        try:
            DB = os.getenv("DB")
            USER=os.getenv("US")
            PASS=os.getenv("PASS")
            db = setup_db(DB, USER, PASS)
            # Make the database cursor
            db_cursor = db.cursor()
        except Exception as e:
            print("%s: Db Exception: %s" % (now(), e), file=LOG)
            LOG.flush()
            sys.exit(1)

#    gauss = 0.88 # Max sensitivity
#    gauss = 1.3 # Sensor default
    gauss = 2.5 # Calibration default
#    gauss = 8.1 # Max scale
    sensor = i2c_hmc5883l(bus, gauss=gauss)
    sensor.setContinuousMode()
#    sensor.setSingleShotMode()
    sensor.setDeclination(7, 8) # Not needed
#    sensor.setScale(gauss)
    sensor.getAxes() # Force a reading
    
    print("Scale: %.2f Gauss. Default gain: %d. Gain factors(+, -):" % (gauss, sensor.getGains()[gauss]), sensor.getGainFactors(), file=LOG)

    while True:
        try:
            (X, Y, Z) = sensor.getAxes()
        except Exception as e:
            print("%s: Sensor Read Exception: %s" % (now(), e), file=LOG)
            LOG.flush()
            time.sleep(1)
            continue
        if mode == 'stdout':
            print("Magnetic Field: (%.4f, %.4f, %.4f) Gauss" % (X, Y, Z))
        elif mode == 'mysql':
            print("%s %.4f, %.4f, %.4f" % (now(), X, Y, Z), file=LOG)
            LOG.flush()
            assert(db_cursor)
            try:
                db_cursor.execute('INSERT INTO `mag` (`X`, `Y`, `Z`, `duration`, `interval`) VALUES (%f, %f, %f, %d, %d);' % (X, Y, Z, 0, interval))
            except Exception as e:
                print("%s: Db Exception: %s" % (now(), e), file=LOG)
                LOG.flush()
                pass
        elif mode == 'table':
            print("%s %.4f %.4f %.4f" % (now(), X, Y, Z), file=LOG)
        time.sleep(interval)
