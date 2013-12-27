:

for T in accel encoder gps
do
	echo $T:
	echo "SELECT UNIX_TIMESTAMP(ts), * FROM $T;" | mysql -uroot -p$P dlogger >$T.csv
done
