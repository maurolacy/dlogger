#!/bin/bash

. /etc/dlogger.conf

DURATION=1	# seconds
INTERVAL=1	# seconds

>/tmp/getencoder.log
while true
do
date | tee -a /tmp/getencoder.log
ANGLE=`$BASE/encoder/serial/getSerialAsync -d $DURATION 2>>/tmp/getencoder.log`
SPEED=0 # FIXME
echo $SPEED | tee -a /tmp/getencoder.log
mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`encoder\` (\`angle\`, \`speed\`, \`duration\`, \`interval\`) VALUES ('$ANGLE', '$SPEED', '$DURATION', '$INTERVAL');
EOF
    D=$[INTERVAL - $DURATION]
    [ $D -gt 0 ] && sleep $D
done
