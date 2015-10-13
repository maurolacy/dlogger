#!/bin/bash
#set -x

. /etc/dlogger.conf
LOG=$BASE/logs/`basename $0 .sh`.log

DURATION=1	 # seconds (Sampling duration. Defined by the reader interface)
INTERVAL=900 # seconds (Sampling interval. Defined by the reader interface)

DRIVER="dht11"  # Kernel driver
GPIO=4
FORMAT=0

DEV="/dev/$DRIVER"

# Configure kernel module and device
insmod $BASE/humidity/kernel_driver/${DRIVER}.ko gpio_pin=$GPIO format=$FORMAT
mknod $DEV c 80 0 
sleep 1

[ -f "$LOG" ] && mv -f $LOG $LOG.bak

while true
do
    L=`cat $DEV`
	H=`echo $L | cut -d\  -f1`
	T=`echo $L | cut -d\  -f2`
	R=`echo $L | cut -d\  -f4`
#	[ "$R" = "BAD" ] && continue
    [ $H -gt 100 ] && R="BAD"
#    [ $T -gt 60 ] && R="BAD"

    echo "$H % $T °C: $R" | tee -a $LOG

    mysql -u$US -p$PASS $DB <<EOF
INSERT INTO \`humidity\` (\`humidity\`, \`temperature\`, \`result\`, \`duration\`, \`interval\`) VALUES ('$H', '$T', '$R', '$DURATION', '$INTERVAL');
EOF
    sleep $INTERVAL
done
