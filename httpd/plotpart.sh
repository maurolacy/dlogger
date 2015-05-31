#!/bin/bash

. /etc/dlogger.conf

DATE=`date '+%m%y'`

MONTH_YEAR=`LANG="es_AR.UTF-8" date '+%B %Y'`
MONTH_YEAR=${MONTH_YEAR^}
MONTHYEAR=`echo $MONTH_YEAR | sed 's/ //'`

DATE1=`date '+%Y-%m-01'`
DATE2=`date --date="next month" '+%Y-%m'`

cd `dirname $0`

mysql -u$US -p$PASS $DB <<EOF >particulas_$DATE.txt
SELECT \`ts\`, \`particles\` FROM \`part\` WHERE \`ts\` > '$DATE1' AND \`ts\` < '$DATE2';
EOF

sed "s/%MONTH_YEAR%/$MONTH_YEAR/;s/%DATE%/$DATE/" particulas.plot >particulas_$DATE.plot

gnuplot particulas_$DATE.plot >/var/www/particulas/Gráfico$MONTHYEAR.png

rm -f particulas_$DATE.txt
rm -f particulas_$DATE.plot

cd - >/dev/null
