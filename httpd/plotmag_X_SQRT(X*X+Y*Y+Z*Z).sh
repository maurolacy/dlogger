#!/bin/bash

. /etc/dlogger.conf

DATE=`date '+%m%y'`

MONTH_YEAR=`LANG="es_AR.UTF-8" date '+%B %Y'`
MONTH_YEAR=${MONTH_YEAR^}
MONTHYEAR=`echo $MONTH_YEAR | sed 's/ //'`

DATE1=`date '+%Y-%m-01'`
DATE2=`date --date="next month" '+%Y-%m-%d'`

cd `dirname $0`
BASE=`basename $0 .sh | sed 's/^plot//'`
TABLE=`echo $BASE | sed 's/_.*//'`
FIELDS=`echo $BASE | sed "s/${TABLE}_//;s/_/ /g"`

[ -n "$1" ] && FIELDS="$FIELDS $1"

sed "s/%BASE%/$BASE/g;s/%MONTH_YEAR%/$MONTH_YEAR/;s/%DATE%/$DATE/g" ${BASE}.plot >${BASE}_$DATE.plot

F=1
for FIELD in $FIELDS
do
	mysql -u$US -p$PASS $DB <<EOF >${BASE}_${FIELD}_$DATE.txt
SELECT \`ts\`, $FIELD FROM \`$TABLE\` WHERE \`ts\` > '$DATE1' AND \`ts\` < '$DATE2' ORDER BY \`ts\`;
EOF
    sed -i "s/%FIELD$F%/$FIELD/" ${BASE}_$DATE.plot
    F=`expr $F + 1`
done

gnuplot ${BASE}_$DATE.plot >$DATA/${BASE}_$MONTHYEAR.png

rm -f ${BASE}_$DATE.plot
for FIELD in $FIELDS
do
	rm -f ${BASE}_${FIELD}_$DATE.txt
done

cd - >/dev/null
