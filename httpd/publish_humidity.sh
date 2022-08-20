:

. /etc/dlogger.conf

echo -n "Creating cron entry..."
cat >/etc/cron.d/humidity-pub <<EOF
# /etc/cron.d/part: crontab entries for humidity publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubhumidity.sh && $BASE/httpd/pubhumidity.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/plothumidity_temperature.sh && $BASE/httpd/plothumidity_temperature.sh >/dev/null
EOF
service cron restart
echo "done."
