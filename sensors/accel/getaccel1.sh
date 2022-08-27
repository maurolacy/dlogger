#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=1	# seconds
INTERVAL=2	# seconds

[ -f "$LOG" ] && mv -f $LOG $LOG.bak
while true
do
	date | tee -a $LOG
	L=`$SENSORS/accel/accel1.py 2>>$LOG`
	echo $L | tee -a $LOG
	X=`echo $L | cut -f1 -d\ `
	Y=`echo $L | cut -f2 -d\ `
	Z=`echo $L | cut -f3 -d\ `
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`accel\` (\`x\`, \`y\`, \`z\`, \`duration\`, \`interval\`) VALUES ('$X', '$Y', '$Z', '$DURATION', '$INTERVAL');
EOF
	D=$[INTERVAL - $DURATION]
	[ $D -gt 0 ] && sleep $D
done
