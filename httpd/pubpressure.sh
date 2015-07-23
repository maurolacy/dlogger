#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DATE1=`date '+%d%m%y'`.txt
DATE2=`date '+%Y-%m-%d'`
mysql -u$US -p$PASS $DB <<EOF >$DATA/$DATE1
SELECT \`ts\`, \`temp\`, \`pressure\` FROM \`pressure\` WHERE \`ts\` > '$DATE2';
EOF
