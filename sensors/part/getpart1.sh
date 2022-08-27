# !/bin/bash
#set -x

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=30	 # seconds (Sampling duration. Defined by the particle reader interface)
INTERVAL=900 # seconds (Sampling interval. Defined by the particle reader interface)

I=`expr $INTERVAL / $DURATION`
#echo $I

[ -f "$LOG" ] && mv -f $LOG $LOG.bak
stty $PART_SPEED <$PART_PORT

OLDPARTS=0
C=0
cat <$PART_PORT | while read L
do
	ID=`echo $L | cut -d, -f1`
	[ -z "$ID" ] && continue
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
	DRIFT=`echo $L | cut -d, -f5`
	SPEED=`echo $L | cut -d, -f6`
	PARTS=`echo $L | cut -d, -f7`
    echo $C: $HOUR $LAT $LON $DRIFT $SPEED: $PARTS | tee -a $LOG
    if [ $PARTS -eq 0 ]
    then
        PARTS=$OLDPARTS
	OLDPARTS=0
    else
        OLDPARTS=$PARTS
    fi
    if [ $C -eq 0 -o $C -ge $I ]
    then
        mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`part\` (\`hour\`, \`lat\`, \`lon\`, \`drift\`, \`speed\`, \`particles\`, \`duration\`, \`interval\`) VALUES ('$HOUR', '$LAT', '$LON', '$DRIFT', '$SPEED', '$PARTS', '$DURATION', '$INTERVAL');
EOF
        C=0
    fi
	C=`expr $C + 1`
done
