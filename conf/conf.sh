:

mkdir -p ../log

PASS=""
while [ ${#PASS} -lt 6 ]
do
  echo -n "Enter the password you want for the dlogger database (min 6 chars): "
  read PASS
done

sed "s/%PASSWORD%/$PASS/" dlogger.conf >/tmp/dlogger.conf.$$

sudo cp -f /tmp/dlogger.conf.$$ /etc
rm -f /tmp/dlogger.conf.$$
