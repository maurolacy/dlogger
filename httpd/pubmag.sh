#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DATE1=`date '+%d%m%y'`.txt
DATE2=`date '+%Y-%m-%d'`
mysql -u$US -p$PASS $DB <<EOF >$DATA/mag_$DATE1
SELECT \`ts\`, \`X\`, \`Y\`, \`Z\` FROM \`mag\` WHERE \`ts\` > '$DATE2';
EOF
