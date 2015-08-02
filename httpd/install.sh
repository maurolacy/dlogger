:

. /etc/dlogger.conf

echo -n "Installing httpd server..."
echo
sudo apt-get update
sudo apt-get -y install apache2 gnuplot
echo "done."
echo -n "Creating data dir '$DATA'..."
sudo mkdir -p $DATA
sudo chown pi $DATA
echo "done."

echo -n "Adding auth configuration..."
cat >/etc/apache2/conf.d/auth.conf <<EOF
<Directory $DATA>
    AuthType Basic
    AuthName PartsAccess
    require valid-user
    AuthUserFile /var/access/auth
</Directory>
EOF
mkdir -p /var/access
touch /var/access/auth
echo -n "Ingrese usuario acceso web server:"
read U
echo -n "Ingrese contraseña:"
htpasswd /var/access/auth $U

service apache2 restart
echo "done."

echo -n "Creating cron entry..."
cat >/etc/cron.d/dlogger-pub <<EOF
# /etc/cron.d/part: crontab entries for dlogger pressure data publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpressure.sh && $BASE/httpd/pubpressure.sh >/dev/null
EOF
service cron restart
echo "done."
