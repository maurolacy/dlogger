#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=60	# seconds
INTERVAL=60	# seconds

# start Geiger
#echo "Starting Geiger counter..."
#$BASE/pport/lpwr 64
#echo "done."
echo -n "Sleeping 1 minute for calibration..."
sleep 60
echo "done."

>$LOG
while true
do
date | tee -a $LOG
COUNT=`$BASE/rad/serial/getSerialAsync -d $DURATION -x 2>>$LOG`
echo $COUNT | tee -a $LOG
mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`rad\` (\`count\`, \`duration\`, \`interval\`) VALUES ('$COUNT', '$DURATION', '$INTERVAL');
EOF
done
