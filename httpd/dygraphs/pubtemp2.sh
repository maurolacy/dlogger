#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

# Join both temp datasets
cat /var/www/html/temp.txt | sed 's/$/\t/' >/tmp/temp2.$$
cat /var/www/html/temperature.txt | sed 's/\t/\t\t/' >>/tmp/temp2.$$

# Soprt by date
sort -nk1 -t\t /tmp/temp2.$$ >/tmp/temp3.txt

# Fix header
cat /tmp/temp3.txt | sed '2s/^[^\t]*\t\t//' | sed '1{N;s/\n//}' >/var/www/html/temp2.txt
