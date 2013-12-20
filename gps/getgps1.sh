#!/bin/bash

. /etc/dlogger.conf

DURATION=1	# seconds
INTERVAL=30	# seconds

>/tmp/getgps.log
while true
do
	date | tee -a /tmp/getgps.log
	L=`/usr/bin/gpspipe -w -n 4 | tail -1 2>>/tmp/getgps.log`
	echo $L | tee -a /tmp/getgps.log

	TIME=`echo $L | cut -d, -f5`
	TIME1=`echo $TIME | cut -d: -f1 | sed 's/\"//g'`
	TIME2=""
	[ "$TIME1" = "time" ] && TIME2=`echo $TIME | cut -d: -f2-`

	LAT=`echo $L | cut -d, -f7`
	LAT1=`echo $LAT | cut -d: -f1 | sed 's/\"//g'`
	LAT2=""
	[ "$LAT1" = "lat" ] && LAT2=`echo $LAT | cut -d: -f2`

	LON=`echo $L | cut -d, -f8`
	LON1=`echo $LON | cut -d: -f1 | sed 's/\"//g'`
	LON2=""
	[ "$LON1" = "lon" ] && LON2=`echo $LON | cut -d: -f2`

	ALT=`echo $L | cut -d, -f9`
	ALT1=`echo $ALT | cut -d: -f1 | sed 's/\"//g'`
	ALT2=""
	[ "$ALT1" = "alt" ] && ALT2=`echo $ALT | cut -d: -f2`
echo $ALT
echo $ALT1
echo $ALT2

	TRACK=`echo $L | cut -d, -f13`
	TRACK1=`echo $TRACK | cut -d: -f1 | sed 's/\"//g'`
	TRACK2=""
	[ "$TRACK1" = "track" ] && TRACK2=`echo $TRACK | cut -d: -f2`
echo $TRACK 
echo $TRACK1
echo $TRACK2

	SPEED=`echo $L | cut -d, -f14`
	SPEED1=`echo $SPEED | cut -d: -f1 | sed 's/\"//g'`
	SPEED2=""
	[ "$SPEED1" = "speed" ] && SPEED2=`echo $SPEED | cut -d: -f2`
echo $SPEED 
echo $SPEED1
echo $SPEED2 

	CLIMB=`echo $L | cut -d, -f15 | sed 's/\}//'`
	CLIMB1=`echo $CLIMB | cut -d: -f1 | sed 's/\"//g'`
	CLIMB2=""
	[ "$CLIMB1" = "climb" ] && CLIMB2=`echo $CLIMB | cut -d: -f2`

#	mysql -u$US -p$PASS $DB <<EOF
	echo INSERT INTO \`gps\` \(\`time\`, \`lat\`, \`lon\`, \`alt\`, \`track\`, \`speed\`, \`climb\`, \`duration\`, \`interval\`\) VALUES \("$TIME2", "$LAT2", "$LON2", "$ALT2", "$TRACK2", "$SPEED2", "$CLIMB2", "$DURATION", "$INTERVAL"\);
#EOF
	sleep $[INTERVAL - $DURATION]
done
