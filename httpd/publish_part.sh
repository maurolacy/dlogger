:

. /etc/dlogger.conf

echo -n "Creating cron entry..."
cat >/etc/cron.d/part <<EOF
# /etc/cron.d/part: crontab entries for particles publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpart.sh && $BASE/httpd/pubpart.sh >/dev/null
EOF
service cron restart
echo "done."
