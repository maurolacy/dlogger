# dlogger
A quick and dirty data logger for the RaspberryPi.

With a modular architecture.

Currently supports:

- Pressure, using the BMP180 sensor.
- Humidity, using the DHT11 sensor.
- Temperature, using both BMP180 and DHT11.
- Magnetometer, using the HMC5883L sensor.

And a number of extra (outdated) drivers for:

- Accelerometer, using the ADXL345 sensor (`./accel`).
- Particle counter, for the Shinyei Model PPD42NS Particle Sensor (`./dust`).
- Particle counter, interfacing through a serial port (`./part`).
- Rotary encoder, using GPIO (`./encoder`).
- GPS, from a serial port through gpsd.
- Geiger counter (Inspector nuclear radiation monitor), interfacing through a serial port (`./rad`).
- Temperature, from a digital clock with a temperature sensor (using ImageMagick and OCR) (`./extra`).

Data aggregation and plotting is done automatically through cron, after a configurable interval (5 minutes).

Plotting is done through the dygraphs JavaScript library, or with ugly gnuplot graphs (old), and published in a local Apache webserver.
