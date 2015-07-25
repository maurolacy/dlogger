#!/bin/bash

. /etc/dlogger.conf

DATE=`date '+%m%y'`

MONTH_YEAR=`LANG="es_AR.UTF-8" date '+%B %Y'`
MONTH_YEAR=${MONTH_YEAR^}
MONTHYEAR=`echo $MONTH_YEAR | sed 's/ //'`

DATE1=`date '+%Y-%m-01'`
DATE2=`date --date="next month" '+%Y-%m'`

cd `dirname $0`
TABLE=`basename $0 .sh | sed 's/^plot//'`
FIELD="$1"
[ -z "$FIELD" ] && FIELD=$TABLE

mysql -u$US -p$PASS $DB <<EOF >${FIELD}_$DATE.txt
SELECT \`ts\`, \`$FIELD\` FROM \`$TABLE\` WHERE \`ts\` > '$DATE1' AND \`ts\` < '$DATE2' ORDER BY \`ts\`;
EOF

sed "s/%MONTH_YEAR%/$MONTH_YEAR/;s/%DATE%/$DATE/;s/%FIELD%/$FIELD/" ${FIELD}.plot >${FIELD}_$DATE.plot

gnuplot ${FIELD}_$DATE.plot >$DATA/${FIELD}_$MONTHYEAR.png

rm -f ${FIELD}_$DATE.txt
rm -f ${FIELD}_$DATE.plot

cd - >/dev/null
