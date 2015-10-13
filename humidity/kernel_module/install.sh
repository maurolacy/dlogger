:

make

sudo rmmod -f dht11km
sudo insmod ./dht11km.ko gpio_pin=4 format=3 
sudo mknod /dev/dht11 c 80 0 
echo "To read the values from the sensor: cat /dev/dht11"
echo
sleep 1
cat /dev/dht11
