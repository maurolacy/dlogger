#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

mysql -u$US -p$PASS $DB <<EOF >$DATA/pressure.txt
SELECT \`ts\`, \`pressure\` FROM \`pressure\`;
EOF
