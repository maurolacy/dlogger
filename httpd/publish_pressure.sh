:

. /etc/dlogger.conf

echo -n "Creating cron entry..."
cat >/etc/cron.d/pressure <<EOF
# /etc/cron.d/part: crontab entries for pressure publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpressure.sh && $BASE/httpd/pubpressure.sh >/dev/null
EOF
service cron restart
echo "done."
