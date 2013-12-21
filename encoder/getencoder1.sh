#!/bin/bash

. /etc/dlogger.conf

DURATION=0	# seconds
INTERVAL=2	# seconds

PORT=16001

>/tmp/getencoder.log
COUNTS=0
OLDCOUNTS=0
while true
do
	date | tee -a /tmp/getencoder.log
	COUNTS=`nc localhost $PORT 2>>/tmp/getencoder.log`
	[ -z "$COUNTS" ] && COUNTS=$OLDCOUNTS
	echo $COUNTS | tee -a /tmp/getencoder.log
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`encoder\` (\`counts\`, \`duration\`, \`interval\`) VALUES ('$COUNTS', '$DURATION', '$INTERVAL');
EOF
	D=$[INTERVAL - $DURATION]
	[ $D -gt 0 ] && sleep $D
	OLDCOUNTS=$COUNTS
done
