#!/bin/bash

. /etc/dlogger.conf

DURATION=1	# seconds
INTERVAL=2	# seconds

>/tmp/getaccel.log
while true
do
	date | tee -a /tmp/getaccel.log
	L=`$BASE/accel/accel1.py 2>>/tmp/getaccel.log`
	echo $L | tee -a /tmp/getaccel.log
	X=`echo $L | cut -f1 -d\ `
	Y=`echo $L | cut -f2 -d\ `
	Z=`echo $L | cut -f3 -d\ `
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`accel\` (\`x\`, \`y\`, \`z\`, \`duration\`, \`interval\`) VALUES ('$X', '$Y', '$Z', '$DURATION', '$INTERVAL');
EOF
	D=$[INTERVAL - $DURATION]
	[ $D -gt 0 ] && sleep $D
done
