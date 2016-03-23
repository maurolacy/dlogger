:

. /etc/dlogger.conf

echo -n "Creating cron entry..."
cat >/etc/cron.d/mag <<EOF
# /etc/cron.d/part: crontab entries for magnetic field publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpressure.sh && $BASE/httpd/pubpressure.sh >/dev/null
EOF
service cron restart
echo "done."
