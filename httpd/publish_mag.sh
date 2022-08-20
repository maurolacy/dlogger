:

. /etc/dlogger.conf

echo -n "Creating cron entry..."
cat >/etc/cron.d/mag-pub <<EOF
# /etc/cron.d/part: crontab entries for magnetic field publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubmag.sh && $BASE/httpd/pubmag.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/plotmag_X_SQRT\(X*X+Y*Y+Z*Z\).sh && /home/pi/work/dlogger/httpd/plotmag_X_SQRT\(X*X+Y*Y+Z*Z\).sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/plotmag_X_Y_Z.sh && $BASE/httpd/plotmag_X_Y_Z.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/plotmag_Y_Z.sh && $BASE/httpd/plotmag_Y_Z.sh >/dev/null
*/15 *    * * *   root   test -x $BASE/httpd/plotmag_X.sh && $BASE/httpd/plotmag_X.sh >/dev/null
EOF
service cron restart
echo "done."
