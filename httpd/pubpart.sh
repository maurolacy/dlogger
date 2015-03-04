#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DATE=`date '+%d%m%y'`.txt
mysql -u$US -p$PASS $DB <<EOF >$DATA/$DATE
SELECT \`ts\`, \`lat\`, \`lon\`, \`particles\` FROM \`part\`;
EOF
