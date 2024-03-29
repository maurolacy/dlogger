#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=5  # seconds
INTERVAL=60 # seconds

[ -f "$LOG" ] && mv -f $LOG $LOG.bak
while true
do
	date

	#get value
	TEMP=`$SENSORS/temp/temp`
	[ -z "$TEMP" -o "$TEMP" = "nan" ] && TEMP=-273.15
	echo $TEMP

	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`temp\` (\`c\`, \`duration\`, \`interval\`) VALUES ('$TEMP', '$DURATION', '$INTERVAL');
EOF
	sleep $[INTERVAL - $DURATION]
done
