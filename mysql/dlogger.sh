:

. /etc/dlogger.conf

echo -n "Installing mysql server..."
echo
sudo apt-get update
sudo apt-get -y install mysql-server screen
echo "done."
echo -n "Creating database '$DB'..."
echo "CREATE DATABASE $DB;" | mysql -u$US -p$PASS mysql 
echo "done."
echo -n "Creating tables..."
mysql -u$US -p$PASS $DB <./dlogger.sql
echo "done."
