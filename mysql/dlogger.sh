:

. /etc/dlogger.conf

echo -n "Installing mysql server..."
echo
sudo apt-get update
sudo apt-get install mysql-server
echo "done."
echo -n "Creating database '$DB'..."
echo "CREATE DATABASE $DB;" | mysql -u$US -p$PASS mysql 
echo "done."
echo -n "Creating tables..."
mysql -u$US -p$PASS $DB <./dlogger.sql
echo "done."
