#!/bin/bash

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

# Join both temp datasets
cat $DATA/temp.txt | sed 's/$/\t/' >/tmp/temp2.$$
cat $DATA/temperature.txt | sed 's/\t/\t\t/' >>/tmp/temp2.$$

# Sort by date
sort -nk1 -t\t /tmp/temp2.$$ >/tmp/temp3.$$

# Fix header
cat /tmp/temp3.$$ | sed '2s/^[^\t]*\t\t//' | sed '1{N;s/\n//}' >$DATA/temp2.txt

# Remove temp files
rm -f /tmp/temp2.$$ /tmp/temp3.$$
