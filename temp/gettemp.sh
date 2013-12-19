#!/bin/bash

. /etc/dlogger.conf

DURATION=5  # seconds
INTERVAL=60 # seconds

while true
do
	date

	#get value
	TEMP=`$BASE/temp/temp`
	[ -z "$TEMP" -o "$TEMP" = "nan" ] && TEMP=-273.15
	echo $TEMP

	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`temp\` (\`c\`, \`duration\`, \`interval\`) VALUES ('$TEMP', '$DURATION', '$INTERVAL');
EOF
	sleep $[INTERVAL - $DURATION]
done
