#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

mysql -u$US -p$PASS $DB <<EOF >$DATA/temperature.txt
SELECT \`ts\`, \`temperature\` FROM \`humidity\` WHERE \`ts\` > CURRENT_TIMESTAMP - INTERVAL $INTERVAL;
EOF
