#!/bin/bash

. /etc/dlogger.conf

DATE=`date '+%m%y'`

MONTH_YEAR=`LANG="es_AR.UTF-8" date '+%B %Y'`
MONTH_YEAR=${MONTH_YEAR^}
MONTHYEAR=`echo $MONTH_YEAR | sed 's/ //'`

DATE1=`date '+%Y-%m-01'`
DATE2=`date --date="next month" '+%Y-%m'`

cd `dirname $0`
BASE=`basename $0 .sh | sed 's/^plot//'`
FIELDS=`echo $BASE | sed 's/_/ /g'`
TABLE=`echo $BASE | sed 's/_.*//'`

[ -n "$1" ] && FIELDS="$FIELDS $1"

sed "s/%MONTH_YEAR%/$MONTH_YEAR/;s/%DATE%/$DATE/g" ${BASE}.plot >${BASE}_$DATE.plot

F=1
for FIELD in $FIELDS
do
	mysql -u$US -p$PASS $DB <<EOF >${FIELD}_$DATE.txt
SELECT \`ts\`, \`$FIELD\` FROM \`$TABLE\` WHERE \`result\` = "OK" and \`ts\` > '$DATE1' AND \`ts\` < '$DATE2' ORDER BY \`ts\`;
EOF
    sed -i "s/%FIELD$F%/$FIELD/" ${BASE}_$DATE.plot
    F=`expr $F + 1`
done

gnuplot ${BASE}_$DATE.plot >$DATA/${BASE}_$MONTHYEAR.png

#rm -f ${BASE}_$DATE.plot
#for FIELD in $FIELDS
#do
#	rm -f ${FIELD}_$DATE.txt
#done

cd - >/dev/null
