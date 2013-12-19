#!/bin/bash

. /etc/dlogger.conf

DURATION=60	# seconds
INTERVAL=60	# seconds

# start Geiger
#echo "Starting Geiger counter..."
#$BASE/pport/lpwr 64
#echo "done."
echo -n "Sleeping 1 minute for calibration..."
sleep 60
echo "done."

>/tmp/getrad.log
while true
do
date | tee -a /tmp/getrad.log
COUNT=`$BASE/rad/serial/getSerialAsync -d $DURATION -x 2>>/tmp/getrad.log`
echo $COUNT | tee -a /tmp/getrad.log
mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`rad\` (\`count\`, \`duration\`, \`interval\`) VALUES ('$COUNT', '$DURATION', '$INTERVAL');
EOF
done
