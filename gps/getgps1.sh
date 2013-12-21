#!/bin/bash

. /etc/dlogger.conf

DURATION=1	# seconds
INTERVAL=2	# seconds

JSHON=$BASE/gps/jshon/jshon

>/tmp/getgps.log
while true
do
	date | tee -a /tmp/getgps.log
	TIME=""
	LAT=""
	LON=""
	ALT=""
	TRACK=""
	SPEED=""
	CLIMB=""
	/usr/bin/gpspipe -w -n 5 | tail -2 >/tmp/gps.$$
	while read L
	do
		# time lat lon alt track speed climb
		[ -z "$TIME" ] && TIME=`echo $L | $JSHON -e time -Q`
		[ -z "$LAT" ] && LAT=`echo $L | $JSHON -e lat -Q`
		[ -z "$LON" ] && LON=`echo $L | $JSHON -e lon -Q`
		[ -z "$ALT" ] && ALT=`echo $L | $JSHON -e alt -Q`
		[ -z "$TRACK" ] && TRACK=`echo $L | $JSHON -e track -Q`
		[ -z "$SPEED" ] && SPEED=`echo $L | $JSHON -e speed -Q`
		[ -z "$CLIMB" ] && CLIMB=`echo $L | $JSHON -e climb -Q`
	done </tmp/gps.$$
	rm -f /tmp/gps.$$
	echo "time: $TIME, lat: $LAT, lon: $LON, alt: $ALT, track: $TRACK, speed: $SPEED, climb: $CLIMB" | tee -a /tmp/getgps.log
	mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`gps\` (\`time\`, \`lat\`, \`lon\`, \`alt\`, \`track\`, \`speed\`, \`duration\`, \`interval\`) VALUES ($TIME, '$LAT', '$LON', '$ALT', '$TRACK', '$SPEED', '$DURATION', '$INTERVAL');
EOF
	D=$[INTERVAL - $DURATION]
	[ $D -gt 0 ] && sleep $D
done
