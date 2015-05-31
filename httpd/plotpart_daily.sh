#!/bin/bash
#set -x

. /etc/dlogger.conf

DATE=`date '+%d%m%y'`

DAY_MONTH_YEAR=`LANG="es_AR.UTF-8" date '+%d %m %Y'`
DAYMONTHYEAR=`echo $DAY_MONTH_YEAR | sed 's/ //g'`

DATE1=`date '+%Y-%m-%d'`
DATE2=`date --date="next day" '+%Y-%m-%d'`

cd `dirname $0`

mysql -u$US -p$PASS $DB <<EOF >particulas_$DATE.txt
SELECT \`ts\`, \`particles\` FROM \`part\` WHERE \`ts\` > '$DATE1' AND \`ts\` < '$DATE2';
EOF

sed "s/%DAY_MONTH_YEAR%/$DAY_MONTH_YEAR/;s/%DATE%/$DATE/" particulas_diario.plot >particulas_$DATE.plot

gnuplot particulas_$DATE.plot >/var/www/particulas/plots/$DAYMONTHYEAR.png

rm -f particulas_$DATE.txt
rm -f particulas_$DATE.plot

cd - >/dev/null
