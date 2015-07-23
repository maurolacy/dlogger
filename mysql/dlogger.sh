:

. /etc/dlogger.conf

echo -n "Installing mysql server..."
echo
#sudo apt-get update
sudo apt-get -y install mysql-server python-mysqldb screen
echo "done."
echo -n "Setting root password..."
/usr/bin/mysql -uroot -Dmysql -e"update user set password=password('$PASS') where user='$US'"
/usr/bin/mysql -uroot -e"flush privileges"
echo "done."
echo -n "Creating database '$DB'..."
echo "CREATE DATABASE $DB;" | mysql -u$US -p$PASS mysql 
echo "done."
echo -n "Creating tables..."
mysql -u$US -p$PASS $DB <./dlogger.sql
echo "done."
