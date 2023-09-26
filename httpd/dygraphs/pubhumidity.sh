#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

mysql -u$US -p$PASS $DB <<EOF >$DATA/humidity.txt
SELECT \`ts\`, \`humidity\` FROM \`humidity\` WHERE \`ts\` > CURRENT_TIMESTAMP - INTERVAL $INTERVAL;
EOF
