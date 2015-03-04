:

. /etc/dlogger.conf

echo -n "Installing httpd server..."
echo
#sudo apt-get update
sudo apt-get -y install apache2
echo "done."
echo -n "Creating data dir '$DATA'..."
sudo mkdir -p $DATA
sudo chown pi $DATA
echo "done."

echo -n "Adding auth configuration..."
cat >/etc/apache2/conf.d/auth.conf <<EOF
<Directory /var/www/particulas>
    AuthType Basic
    AuthName PartsAccess
    require valid-user
    AuthUserFile /var/access/auth
</Directory>
EOF
mkdir -p /var/access
touch /var/access/auth
echo -n "Ingrese usuario para lectura de particulas:"
read U
echo -n "Ingrese contraseña:"
htpasswd /var/access/auth $U

service apache2 restart
echo "done."

echo -n "Creating cron entry..."
cat >/etc/cron.d/part <<EOF
# /etc/cron.d/part: crontab entries for particles publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpart.sh && $BASE/httpd/pubpart.sh >/dev/null
EOF
service cron restart
echo "done."
