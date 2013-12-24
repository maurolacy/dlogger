#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=0	# seconds
INTERVAL=2	# seconds

PORT=16001

>$LOG
COUNTS=0
OLDCOUNTS=0
while true
do
	date | tee -a $LOG
	COUNTS=`nc localhost $PORT 2>>$LOG`
	[ -z "$COUNTS" ] && COUNTS=$OLDCOUNTS
	echo $COUNTS | tee -a $LOG
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`encoder\` (\`counts\`, \`duration\`, \`interval\`) VALUES ('$COUNTS', '$DURATION', '$INTERVAL');
EOF
	D=$[INTERVAL - $DURATION]
	[ $D -gt 0 ] && sleep $D
	OLDCOUNTS=$COUNTS
done
