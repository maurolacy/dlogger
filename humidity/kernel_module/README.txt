http://www.tortosaforum.com/raspberrypi/dht11driver.htm

Driver file


By default the DHT11 is connected to GPIO pin 0 (pin 3 on the GPIO connector).
I know very little about Linux so getting this to work is a bit of a hack - I know there are other ways (with modprobe) but I have yet to explore this art.. 
The following works on my system...
The driver Major version default is 80 but can be set via the command line.

Command line parameters: 
gpio_pin=X - a valid GPIO pin value 
driverno=X - value for Major driver number
format=X - format of the output from the sensor 

Usage:


Load driver: insmod ./dht11km.ko 
i.e. insmod ./dht11km.ko gpio_pin=2 format=3 

Set up device file to read from (i.e.): 
mknod /dev/dht11 c 80 0 
mknod /dev/myfile c 0   - to set the output to your own file and driver number 

To read the values from the sensor: cat /dev/dht11

Validity of the return results are indicated ny OK or BAD as the last field in the results string.
Issues

Sometimes the readings are a bit odd. It appears a bit gets mis-interpreted or lost; the timing is critical and the microsecond delays are too fast for the RaspberryPi at times. 
There is a retry strategy built into the driver but sometimes a bad result is still returned.
