:

make

sudo rmmod -f dht11
sudo insmod ./dht11.ko gpio_pin=4 format=3
sudo mknod /dev/dht11 c 80 0 
echo "To read the values from the sensor: cat /dev/dht11"
echo
sleep 1
cat /dev/dht11
