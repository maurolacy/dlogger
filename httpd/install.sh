:

. /etc/dlogger.conf

echo -n "Installing httpd server..."
echo
sudo apt update
sudo apt -y install apache2 gnuplot
echo "done."
echo -n "Creating data dir '$DATA'..."
sudo mkdir -p $DATA
sudo chown pi $DATA
echo "done."

echo -n "Adding auth configuration..."
cat <<EOF | sudo tee /etc/apache2/conf-available/auth.conf
<Directory $DATA>
    AuthType Basic
    AuthName PartsAccess
    require valid-user
    AuthUserFile /var/access/auth
</Directory>
EOF
sudo ln -s /etc/apache2/conf-available/auth.conf /etc/apache2/conf-enabled/
sudo mkdir -p /var/access
sudo touch /var/access/auth
echo -n "Ingrese usuario acceso web server:"
read U
echo -n "Ingrese contraseña:"
sudo htpasswd /var/access/auth $U

sudo service apache2 restart
echo "done."

echo -n "Creating cron entry..."
cat <<EOF | sudo tee /etc/cron.d/dlogger-pub
# /etc/cron.d/part: crontab entries for dlogger pressure data publication

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/15 *    * * *   root   test -x $BASE/httpd/pubpressure.sh && $BASE/httpd/pubpressure.sh >/dev/null
EOF
sudo service cron restart
echo "done."
