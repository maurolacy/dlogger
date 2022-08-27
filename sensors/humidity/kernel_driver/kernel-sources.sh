:

cd /usr/src
# Or use rpi-source
git clone --depth 1 https://github.com/raspberrypi/linux.git
ln -s linux linux-`uname -r`
cd linux
modprobe configs
zcat /proc/config.gz >.config
cd /lib/modules/`uname -r`
ln -s /usr/src/linux build
