#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=30	# seconds (Sampling duration. Defined by the particle reader interface)
INTERVAL=30	# seconds (Sampling interval. Defined by the particle reader interface)

[ -f "$LOG" ] && mv -f $LOG $LOG.bak
stty $PART_SPEED <$PART_PORT

cat <$PART_PORT | while read L
do
	ID=`echo $L | cut -d, -f1`
	HOUR=`echo $L | cut -d, -f2`
	LAT=`echo $L | cut -d, -f3`
	if echo $LAT | grep -q 'S$'
	then
		LAT=-`echo $LAT | sed 's/.$//'`
	else
		LAT=`echo $LAT | sed 's/.$//'`
	fi
	LON=`echo $L | cut -d, -f4`
	if echo $LON | grep -q 'W$'
	then
		LON=-`echo $LON | sed 's/.$//'`
	else
		LON=`echo $LON | sed 's/.$//'`
	fi
	COUNT1=`echo $L | cut -d, -f5`
	COUNT2=`echo $L | cut -d, -f6`
	COUNT3=`echo $L | cut -d, -f7`
	echo $ID $HOUR $LAT $LON: $COUNT1 $COUNT2 $COUNT3 | tee -a $LOG
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`part\` (\`id\`, \`hour\`, \`lat\`, \`lon\`, \`count1\`, \`count2\`, \`count3\`, \`duration\`, \`interval\`) VALUES ('$ID', '$HOUR', '$LAT', '$LON', '$COUNT1', '$COUNT2', '$COUNT3', '$DURATION', '$INTERVAL');
EOF
done
