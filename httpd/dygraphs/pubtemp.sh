#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

mysql -u$US -p$PASS $DB <<EOF >$DATA/temp.txt
SELECT \`ts\`, \`temp\` FROM \`pressure\`;
EOF
